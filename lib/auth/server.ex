defmodule Whatsapp.Auth.Server do
  @moduledoc """
  GenServer para manejo de la generación de tokens para autenticación
  """

  # Every 24 hours
  @daily 24 * 60 * 60 * 1_000
  @server WhatsappAuthServer

  require Logger

  use GenServer

  alias __MODULE__
  alias Whatsapp.Auth.Manager
  alias Whatsapp.Models.WhatsappProvider

  @doc """
  Callback de inicio del GenServer
  """
  @spec init(Keyword.t()) :: {:ok, any()}
  def init(args) do
    Process.flag(:trap_exit, true)
    Logger.info("Whatsapp Auth System online")
    providers =
      args
      |> Keyword.fetch!(:providers)
      |> _remove_invalid_providers()
      |> Enum.map(&(struct(WhatsappProvider, &1)))

    schedule_token_check()
    {
      :ok, %{
        tokens: get_tokens_info(providers),
        providers: providers
      }
    }
  end

  @doc """
  Inicia el GenServer para manejo de la autenticación de Whatsapp
  """
  @spec start_link(list) :: any()
  def start_link(providers) do
    GenServer.start_link(Server, [providers: providers], name: @server)
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
  Callback al terminar el GenServer. Hace logout de todos los servicios de
  Whatsapp guardados
  """
  @spec terminate(atom, map) :: any()
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

  @doc """
  Handler del GenServer para la llamada asincrona
  tipo info para token check diario
  """
  @spec handle_info(:token_check, any()) :: {:noreply, any()}
  def handle_info(:token_check, %{tokens: tokens, providers: providers} = state) do
    Logger.info("Checking tokens")
    tokens = update_expired_tokens(providers, tokens)
    schedule_token_check()
    {:noreply, Map.put(state, :tokens, tokens)}
  end

  @doc """
  Lista los tokens guardados
  """
  @spec handle_call(:list, PID, map) :: {:reply, map, map}
  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  @doc """
  Handler del GenServer para llamada sincrona para
  obtener el token de un producto
  """
  @spec handle_call({:lookup_token, binary()}, any(), any()) :: {:reply, any(), any()}
  def handle_call({:lookup_token, product}, _from, state) do
    %{"token" => token, "url" => url} = Map.get(state.tokens, product)
    {:reply, {url, get_auth_header(token)}, state}
  end

  defp get_auth_header(token) do
    {"Authorization", "Bearer #{token}"}
  end

  # Programa el siguiente check de tokens
  @spec schedule_token_check :: any()
  defp schedule_token_check do
    Process.send_after(self(), :token_check, @daily)
  end

  def update_expired_tokens(providers, credentials) do
    Enum.reduce(
      providers,
      %{},
      fn provider, credentials ->
        credentials_product = Map.get(credentials, provider.name)
        expires = Map.get(credentials_product, "expires_after")
        hours_diff = (expires && Timex.diff(expires, Timex.now(), :hours)) || 0

        credentials = (hours_diff < 24 && Manager.login(provider)) || credentials

        Map.put(
          credentials,
          provider.name,
          Map.put(credentials, "url", provider.url)
        )
    end)
  end

  def get_tokens_info(providers) do
    Enum.reduce(
      providers,
      %{},
      fn provider, credentials  ->
        credentials_provider =
          provider
          |> Manager.login()
          |> Map.put("url", provider.url)

        Map.put(
          credentials,
          provider.name,
          credentials_provider
        )
    end)
  end

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
end
