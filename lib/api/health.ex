defmodule Whatsapp.Api.Health do
  @moduledoc """
  Módulo para el manejo de la salud de Whatsapp
  """

  @parser Application.get_env(:wax, :parser)

  def get_summary({url, auth_header}) do
    url
    |> Kernel.<>("/health")
    |> WhatsappApiRequest.rate_limit_request(:get!, [auth_header])
    |> @parser.parse(:get_health)
  end
end
