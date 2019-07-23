defmodule Whatsapp.Api.Users do
  @moduledoc """
  Módulo para manejo de autenticación con Whatsapp
  """


  alias WhatsappApiRequest

  @doc """
  Login para generar token de autenticación
  """
  @spec login(binary()) :: map
  def login(token) do
    headers = [{"Authorization", "Basic #{token}"}]

    WhatsappApiRequest.post("/users/login", headers)
  end

  @doc """
  Logout de la sesión del usuario
  """
  @spec logout(binary()) :: map
  def logout(token) do
    headers = [{"Authorization", "Bearer #{token}"}]

    # Se manda `auth: false` porque el Berear token no se toma del
    # GenServer de Tokens sino viene como parámetro
    WhatsappApiRequest.post("/users/logout", headers)
  end
end
