defmodule Whatsapp.Api.Settings do
  @moduledoc """
  Módulo para el manejo de la configuración de Whatsapp
  """

  @parser Application.get_env(:wax, :parser)

  @doc """
  Obtiene la configuración de la cuenta
  """
  @spec get_application(tuple()) :: boolean
  def get_application({url, auth_header}) do
    url
    |> Kernel.<>("/settings/application")
    |> WhatsappApiRequest.rate_limit_request(:get!, nil, [auth_header])
    |> @parser.parse(:settings_get_application)
  end

  @doc """
  Actualiza la configuración de la cuenta
  """
  @spec update_application(tuple(), map()) :: boolean
  def update_application({url, auth_header}, data) do
    url
    |> Kernel.<>("/settings/application")
    |> WhatsappApiRequest.rate_limit_request(:patch!, data, [auth_header])
    |> @parser.parse(:settings_update_application)
  end

  @doc """
  Actualiza la configuración de la cuenta
  """
  @spec two_step(tuple(), String.t()) :: boolean
  def two_step({url, auth_header}, pin) do
    url
    |> Kernel.<>("/settings/account/two-step")
    |> WhatsappApiRequest.rate_limit_request(:post!, %{"pin" => pin}, [auth_header])
    |> @parser.parse(:settings_two_step)
  end
end
