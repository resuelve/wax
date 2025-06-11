defmodule Whatsapp.Api.Users do
  @moduledoc """
  Módulo para manejo de autenticación con Whatsapp
  """

  @parser Application.compile_env(:wax, :parser)

  alias WhatsappApiRequest

  @doc """
  Login for any kind of user
  """
  @spec login(tuple()) :: map
  def login({url, auth_header}) do
    url
    |> Kernel.<>("/users/login")
    |> WhatsappApiRequest.post!(nil, [auth_header])
    |> @parser.parse(:users_login)
  end

  @doc """
  Logout from some account
  """
  @spec logout(tuple()) :: map
  def logout({url, auth_header}) do
    url
    |> Kernel.<>("/users/logout")
    |> WhatsappApiRequest.post!(nil, [auth_header])
    |> @parser.parse(:users_logout)
  end

  @doc """
  Create user account
  """
  @spec create(tuple(), map) :: map
  def create({url, auth_header}, data) do
    url
    |> Kernel.<>("/users")
    |> WhatsappApiRequest.post!(data, [auth_header])
    |> @parser.parse(:users_create)
  end
end
