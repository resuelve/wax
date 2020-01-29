defmodule Whatsapp.Auth.Manager do
  @moduledoc """
  Manager para la autenticación de Whatsapp
  """

  require Logger

  alias Whatsapp.Models.WhatsappProvider
  alias Whatsapp.Api.Users

  @doc """
  Generar nuevo token de login
  """
  @spec login(WhatsappProvider.t()) :: map
  def login(%WhatsappProvider{} = provider) do
    auth_header = generate_login_auth_header(provider.username, provider.password)

    case Users.login({provider.url, auth_header}) do
      %{"users" => [login_data]} ->
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
    auth_header = {"Authorization", "Bearer #{token}"}

    case Users.logout({provider.url, auth_header}) do
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
  Genera el header para autenticarse con el servicio de Whatsapp
  """
  @spec generate_login_auth_header(String.t(), String.t()) :: binary()
  def generate_login_auth_header(username, password) do
    token = Base.encode64("#{username}:#{password}")
    {"Authorization", "Basic #{token}"}
  end
end
