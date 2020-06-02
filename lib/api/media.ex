defmodule Whatsapp.Api.Media do
  @moduledoc """
  Modulo para el manejo de archivos media de Whatsapp
  """

  @parser Application.get_env(:wax, :parser)

  alias Whatsapp.Models.MessageOutboundMedia
  alias WhatsappApiRequestMedia

  require Logger

  @doc """
  Carga el archivo al servidor de Whatsapp
  """
  @spec upload(tuple(), Media.t()) :: tuple
  def upload({url, auth_header}, %MessageOutboundMedia{data: data, mime_type: mime_type}) do
    headers = [{"Content-Type", mime_type}, auth_header]

    url
    |> Kernel.<>("/media")
    |> WhatsappApiRequestMedia.rate_limit_request(:post!, data, headers)
    |> @parser.parse(:media_upload)
  end

  @doc """
  Obtiene el archivo media del servidor de la aplicación de Whatsapp
  """
  @spec download(tuple(), integer | String.t()) :: tuple
  def download({url, auth_header}, media_id) do
    url
    |> Kernel.<>("/media/#{media_id}")
    |> WhatsappApiRequestMedia.rate_limit_request(:get!, [auth_header])
    |> @parser.parse(:media_download)
  end

  @doc """
  Elimina un archivo media en el servidor de Whatsapp
  """
  @spec delete(tuple(), integer | String.t()) :: tuple
  def delete({url, auth_header}, media_id) do
    url
    |> Kernel.<>("/media/#{media_id}")
    |> WhatsappApiRequestMedia.rate_limit_request(:delete!, [auth_header])
    |> @parser.parse(:media_delete)
  end
end
