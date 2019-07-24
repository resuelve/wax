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
    case Users.login(generate_token(provider)) do
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
    case Users.logout(token) do
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
    Base.encode64("#{username}:#{password}")
  end
end
