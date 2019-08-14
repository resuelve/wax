defmodule Whatsapp.Api.Media do
  @moduledoc """
  Modulo para el manejo de archivos media de Whatsapp
  """

  @parser Application.get_env(:whatsapp_api, :parser)

  alias Whatsapp.Models.MessageOutboundMedia
  alias Whatsapp.Models.MediaDownload
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
  @spec download(tuple(), MediaDownload.t()) :: tuple
  def download({url, auth_header}, %MediaDownload{} = media) do
    # Se envia no_parse: true para que no intente convertir la respuesta a JSON
    media_response =
      url
      |> Kernel.<>("/media/#{media.id}")
      |> WhatsappApiRequestMedia.rate_limit_request(:get!, nil, [auth_header])
      |> @parser.parse(:media_download)

    {:ok, path} = Briefly.create(extname: ".#{media.extension}")
    File.write!(path, media_response)
    {:ok, path}
  end
end
