defmodule Whatsapp.Api.Users do
  @moduledoc """
  Módulo para manejo de autenticación con Whatsapp
  """

  @parser Application.get_env(:wax, :parser)

  alias WhatsappApiRequest

  @doc """
  Login para generar token de autenticación
  """
  @spec login(String.t(), binary()) :: map
  def login(url, token) do
    headers = [{"Authorization", "Basic #{token}"}]

    url
    |> Kernel.<>("/users/login")
    |> WhatsappApiRequest.post!(nil, headers)
    |> @parser.parse(:users_login)
  end

  @doc """
  Logout de la sesión del usuario
  """
  @spec logout(String.t(), binary()) :: map
  def logout(url, token) do
    headers = [{"Authorization", "Bearer #{token}"}]

    url
    |> Kernel.<>("/users/logout")
    |> WhatsappApiRequest.post(nil, headers)
    |> @parser.parse(:users_logout)
  end
end
