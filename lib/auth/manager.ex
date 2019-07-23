defmodule Qbox.Whatsapp.Auth.Manager do
  @moduledoc """
  Manager para la autenticación de Whatsapp
  """

  require Logger

  alias Whatsapp.Models.WhatsappProvider
  alias Qbox.Whatsapp.Auth

  @doc """
  Generar nuevo token de login
  """
  @spec login(WhatsappProvider.t()) :: map
  def login(%WhatsappProvider{wa_account: wa_account} = provider) do
    case Auth.login(provider, generate_token(wa_account)) do
      {:ok, %{"users" => [login_data]}} ->
        expires =
          login_data
          |> Map.get("expires_after")
          |> Timex.parse!("{YYYY}-{0M}-{0D} {h24}:{m}:{s}{Z:}")

        Logger.info(fn ->
          "Whatsapp token received for [#{provider.name}] expires on #{expires}"
        end)

        Map.put(login_data, "expires_after", expires)

      _ ->
        Logger.error(fn -> "Whatsapp login failed for #{provider.name}" end)
        %{}
    end
  end

  @doc """
  Logout de la sesión de Whatsapp
  """
  @spec logout(WhatsappProvider.t(), binary()) :: :ok | :error
  def logout(%WhatsappProvider{} = provider, token) do
    case Auth.logout(provider, token) do
      {:ok, _} ->
        Logger.info(fn -> "Logout #{provider.name} successful" end)
        :ok

      {:error, [error]} ->
        Logger.error(fn ->
          "Whatsapp logout failed for #{provider.name}: #{error["details"]}"
        end)
        :error
    end
  end

  @doc """
  Genera el token para autenticarse con el servicio de Whatsapp
  """
  @spec generate_token(map) :: binary()
  def generate_token(%{username: username, password: password}) do
    decrypt_password = Cipher.decrypt(password)
    Base.encode64("#{username}:#{decrypt_password}")
  end
end
