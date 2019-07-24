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

  @doc """
  Callback de inicio del GenServer
  """
  @spec init(Keyword.t()) :: {:ok, any()}
  def init(args) do
    Process.flag(:trap_exit, true)
    Logger.info("Whatsapp Auth System online")
    providers = Keyword.fetch!(args, :providers)

    tokens =
      providers
      |> get_new_tokens()

    schedule_token_check()
    {:ok, %{tokens: tokens, providers: providers}}
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
  Obtiene el token de autenticación del producto dado
  """
  @spec get_token(binary()) :: binary() | nil
  def get_token(product) do
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
  def handle_info(:token_check, state) do
    Logger.info("Checking tokens")
    tokens = get_new_tokens(state)
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
    token = get_in(state.tokens, [product, "token"]) || ""
    {:reply, token, state}
  end

  # Programa el siguiente check de tokens
  @spec schedule_token_check :: any()
  defp schedule_token_check do
    Process.send_after(self(), :token_check, @daily)
  end

  @doc """
  Obtiene los token nuevos o genera un token de prueba
  """
  @spec get_new_tokens(boolean) :: map
  def get_new_tokens(%{tokens: false}) do
    %{
      "test" => %{
        "token" => "TOKEN",
        "expires_after" => Timex.now() |> Timex.shift(hours: 12)
      }
    }
  end

  def get_new_tokens(%{tokens: tokens}) when is_map(tokens) do
    tokens
    |> Map.keys()
    |> Enum.reduce(%{}, fn product, acc ->
      token = Map.get(tokens, product)
      expires = Map.get(token, "expires_after")
      hours_diff = (expires && Timex.diff(expires, Timex.now(), :hours)) || 0

      token = (hours_diff < 24 && Manager.login(product)) || token
      Map.put(acc, product, token)
    end)
  end

  def get_new_tokens(providers) do
    providers
    |> Enum.reduce(%{}, fn provider, tokens ->
      Map.put(tokens, provider.name, Manager.login(provider))
    end)
  end
end
