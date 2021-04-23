defmodule Whatsapp.Auth.Server do
  @moduledoc """
  GenServer para manejo de la generación de tokens para autenticación
  """

  # Every 24 hours
  @daily 24 * 60 * 60 * 1_000
  @server __MODULE__

  require Logger

  use GenServer

  alias Whatsapp.Auth.Manager
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
  def handle_info(:token_check, %{providers: providers} = state) do
    Logger.info("Checking tokens")
    tokens = update_expired_tokens(providers)
    schedule_token_check()
    {:noreply, Map.put(state, :tokens, tokens)}
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:lookup_token, product}, _from, state) do
    %{"token" => token, "url" => url} = Map.get(state.tokens, product)
    {:reply, {url, get_auth_header(token)}, state}
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

  def update_expired_tokens(providers) do
    Enum.reduce(providers, %{}, fn provider, credentials ->
      credentials_product = Map.get(credentials, provider.name)
      expires = Map.get(credentials_product, "expires_after")
      hours_diff = (expires && Timex.diff(expires, Timex.now(), :hours)) || 0

      credentials = (hours_diff < 24 && Manager.login(provider)) || credentials

      Map.put(credentials, provider.name, Map.put(credentials, "url", provider.url))
    end)
  end

  def get_tokens_info(providers) do
    Enum.reduce(providers, %{}, fn provider, credentials ->
      try do
        credentials_provider =
          provider
          |> Manager.login()
          |> Map.put("url", provider.url)

        Map.put(credentials, provider.name, credentials_provider)
      rescue
        error ->
          previous_errors = Map.get(credentials, :errors, [])
          errors = [{provider.name, inspect(error)} | previous_errors]
          Map.put(credentials, :errors, errors)
      end
    end)
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
