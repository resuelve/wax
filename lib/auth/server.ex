defmodule Qbox.Whatsapp.Auth.Server do
  @moduledoc """
  GenServer para manejo de la generación de tokens para autenticación
  """

  # Every 24 hours
  @daily 24 * 60 * 60 * 1_000

  require Logger

  use GenServer

  alias Qbox.Managers.Providers.WhatsappProviderManager
  alias Qbox.Whatsapp.Auth.Manager

  @doc """
  Callback de inicio del GenServer
  """
  @spec init(any()) :: {:ok, any()}
  def init(_) do
    Logger.info("Whatsapp Auth System online")

    tokens =
      :qbox
      |> Application.get_env(:create_wa_auth_token)
      |> get_new_tokens()

    schedule_token_check()
    {:ok, tokens}
  end

  @doc """
  Callback al terminar el GenServer. Hace logout de todos los servicios de
  Whatsapp guardados
  """
  @spec terminate(atom, map) :: any()
  def terminate(_reason, state) do
    [type: "whatsapp"]
    |> WhatsappProviderManager.get_all()
    |> Enum.reduce(%{}, fn provider, tokens ->
      token =
        state
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
    {:noreply, tokens}
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
  @spec handle_call({:lookup_token, binary()}, any(), any()) ::
          {:reply, any(), any()}
  def handle_call({:lookup_token, product}, _from, tokens) do
    token = get_in(tokens, [product, "token"]) || ""
    {:reply, token, tokens}
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
  def get_new_tokens(false) do
    %{
      "test" => %{
        "token" => "TOKEN",
        "expires_after" => Timex.now() |> Timex.shift(hours: 12)
      }
    }
  end

  def get_new_tokens(tokens) when is_map(tokens) do
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

  def get_new_tokens(_) do
    [type: "whatsapp"]
    |> WhatsappProviderManager.get_all()
    |> Enum.reduce(%{}, fn provider, tokens ->
      Map.put(tokens, provider.name, Manager.login(provider))
    end)
  end
end
