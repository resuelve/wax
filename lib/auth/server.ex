defmodule Whatsapp.Auth.Server do
  @moduledoc """
  GenServer para manejo de la generación de tokens para autenticación
  """

  # Every 24 hours
  @daily 24 * 60 * 60 * 1_000
  @five_minute 5 * 60 * 1_000
  @server __MODULE__

  require Logger

  use GenServer

  alias Whatsapp.Auth.{Manager, Token}
  alias Whatsapp.Models.WhatsappProvider

  @doc """
  Carga la configuración de los providers dados y los autentica
  """
  @spec load_config(map() | [map()]) :: :ok
  def load_config(config) when is_map(config) do
    load_config([config])
  end

  def load_config([_ | _] = config) do
    GenServer.cast(@server, {:load_providers_config, config})
  end

  @doc """
  Lista todos los tokens guardados
  """
  @spec list_tokens() :: list
  def list_tokens() do
    GenServer.call(@server, :list)
  end

  @doc """
  Obtiene el token de autenticación y la url del producto dado
  """
  @spec get_token_info(binary()) :: binary() | nil
  def get_token_info(product) do
    GenServer.call(@server, {:lookup_token, product})
  end

  @doc """
  Inicia el GenServer para manejo de la autenticación de Whatsapp
  """
  @spec start_link(list) :: any()
  def start_link(providers \\ []) do
    GenServer.start_link(@server, providers, name: @server)
  end

  @doc """
  Callback de inicio del GenServer
  """
  @impl true
  def init(providers) do
    Process.flag(:trap_exit, true)
    Logger.info("Whatsapp Auth System online")
    schedule_token_check()

    {:ok, do_load_config(providers)}
  end

  @doc """
  Callback al terminar el GenServer. Hace logout de todos los servicios de
  Whatsapp guardados
  """
  @impl true
  def terminate(_reason, state) do
    state.providers
    |> Enum.reduce(%{}, fn provider, tokens ->
      token =
        state.tokens
        |> Map.get(provider.name)
        |> Map.get("token")

      Map.put(tokens, provider.name, Manager.logout(provider, token))
    end)
  end

  @impl true
  def handle_info(:token_check, %{providers: providers, tokens: tokens} = state) do
    Logger.info("Checking tokens")
    updated_tokens = update_expired_tokens(providers, tokens)
    schedule_token_check()
    {:noreply, Map.put(state, :tokens, updated_tokens)}
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:lookup_token, product}, _from, state) do
    case Map.get(state.tokens, product) do
      %{"token" => token, "url" => url} ->
        {:reply, {url, get_auth_header(token)}, state}

      _ ->
        {:reply, {:error, "Token not available"}, state}
    end
  end

  @impl true
  def handle_cast({:load_providers_config, []}, state) do
    {:noreply, state}
  end

  def handle_cast({:load_providers_config, providers}, state) do
    new_state =
      case do_load_config(providers) do
        %{tokens: new_tokens, providers: new_providers} ->
          state
          |> Map.update!(:providers, &update_providers(&1, new_providers))
          |> Map.update!(:tokens, &update_tokens(&1, new_tokens))

        _ ->
          state
      end

    {:noreply, new_state}
  end

  # Actualiza la configuración sólo de los providers que se recibieron
  @spec update_providers([map()], [map()]) :: [map()]
  defp update_providers([], new_providers) do
    new_providers
  end

  defp update_providers(providers, new_providers) do
    providers
    |> Enum.filter(fn %{name: provider_name} ->
      case Enum.find(new_providers, &(&1.name == provider_name)) do
        nil ->
          true

        _ ->
          false
      end
    end)
    |> Kernel.++(new_providers)
  end

  # Actualiza los tokens sólo de los providers que se recibieron
  @spec update_tokens(map(), map()) :: map()
  defp update_tokens(tokens, new_tokens) do
    Map.merge(tokens, new_tokens)
  end

  defp get_auth_header(token) do
    {"Authorization", "Bearer #{token}"}
  end

  # Programa el siguiente check de tokens
  @spec schedule_token_check :: any()
  defp schedule_token_check do
    Process.send_after(self(), :token_check, @daily)
  end

  def update_expired_tokens(providers, stored_tokens) do
    Logger.info("Updating tokens")

    result =
      Enum.reduce(providers, %{}, fn provider, providers_tokens_data ->
        token_data = Map.get(stored_tokens, provider.name)

        if token_data != nil do
          expires = Map.get(token_data, "expires_after")
          hours_diff = (expires && Timex.diff(expires, Timex.now(), :hours)) || 0

          if hours_diff < 24 do
            Token.renew(provider, providers_tokens_data)
          else
            Map.put(providers_tokens_data, provider.name, token_data)
          end
        else
          Token.renew(provider, providers_tokens_data)
        end
      end)

    validate_error(result)
  end

  def get_tokens_info(providers) do
    result =
      Enum.reduce(providers, %{}, fn provider, providers_tokens_data ->
        Token.renew(provider, providers_tokens_data)
      end)

    validate_error(result)
  end

  def validate_error(result) do
    if Map.has_key?(result, :errors) do
      Logger.error("There are error in fetching tokens credentials")
      Process.send_after(self(), :token_check, @five_minute)
    end

    result
  end

  # Remueve las configuraciones inválidas de providers
  @spec _remove_invalid_providers([map()]) :: [map()]
  defp _remove_invalid_providers([]), do: []

  defp _remove_invalid_providers([%{username: nil} | tail]) do
    _remove_invalid_providers(tail)
  end

  defp _remove_invalid_providers([%{username: ""} | tail]) do
    _remove_invalid_providers(tail)
  end

  defp _remove_invalid_providers([provider | tail]) do
    [provider | _remove_invalid_providers(tail)]
  end

  # Carga la configuración de los providers dados. Esto incluye
  # hacer login para obtener el token de cada uno
  @spec do_load_config([map()]) :: map()
  defp do_load_config([]) do
    Logger.info(fn -> "No Whatsapp Configs loaded" end)
    %{tokens: %{}, providers: []}
  end

  defp do_load_config(providers) do
    providers =
      providers
      |> _remove_invalid_providers()
      |> Enum.map(&struct(WhatsappProvider, &1))

    %{
      tokens: get_tokens_info(providers),
      providers: providers
    }
  end
end
