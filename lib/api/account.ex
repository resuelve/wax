defmodule Whatsapp.Api.Account do
  @moduledoc """
  Módulo para el manejo de la configuración de Whatsapp
  """

  @parser Application.compile_env(:wax, :parser)

  @doc """
  Registrar una cuenta en Whatsapp
  """
  @spec create(tuple(), map) :: boolean
  def create({url, auth_header}, data) do
    url
    |> Kernel.<>("/account")
    |> WhatsappApiRequest.post!(data, [auth_header])
    |> @parser.parse(:account)
  end

  @doc """
  Verificar la cuenta con el código recibido en el móvil
  """
  @spec create(tuple(), map) :: boolean
  def verify({url, auth_header}, code) do
    url
    |> Kernel.<>("/account/verify")
    |> WhatsappApiRequest.post!(%{"code" => code}, [auth_header])
    |> @parser.parse(:account)
  end
end
