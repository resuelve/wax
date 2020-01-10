defmodule Whatsapp.Api.Users do
  @moduledoc """
  Módulo para manejo de autenticación con Whatsapp
  """

  @parser Application.get_env(:wax, :parser)

  alias WhatsappApiRequest

  @doc """
  Login para generar token de autenticación
  """
  @spec login(tuple()) :: map
  def login({url, auth_header}) do
    url
    |> Kernel.<>("/users/login")
    |> WhatsappApiRequest.post!(nil, [auth_header])
    |> @parser.parse(:users_login)
  end

  @doc """
  Logout de la sesión del usuario
  """
  @spec logout(tuple()) :: map
  def logout({url, auth_header}) do
    url
    |> Kernel.<>("/users/logout")
    |> WhatsappApiRequest.post!(nil, [auth_header])
    |> @parser.parse(:users_logout)
  end
end
