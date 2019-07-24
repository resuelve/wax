defmodule Whatsapp.Api.Users do
  @moduledoc """
  Módulo para manejo de autenticación con Whatsapp
  """

  @parser Application.get_env(:whatsapp_api, :parser)

  alias WhatsappApiRequest

  @doc """
  Login para generar token de autenticación
  """
  @spec login(binary()) :: map
  def login(token) do
    headers = [{"Authorization", "Basic #{token}"}]

    "/users/login"
    |> WhatsappApiRequest.post!(nil, headers)
    |> @parser.parse(:users_login)
  end

  @doc """
  Logout de la sesión del usuario
  """
  @spec logout(binary()) :: map
  def logout(token) do
    headers = [{"Authorization", "Bearer #{token}"}]

    "/users/logout"
    |> WhatsappApiRequest.post(nil, headers)
    |> @parser.parse(:users_logout)
  end
end
