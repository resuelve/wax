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
  @spec upload(Media.t(), tuple()) :: tuple
  def upload(%MessageOutboundMedia{data: data, mime_type: mime_type}, auth_header) do
    headers = [{"Content-Type", mime_type}, auth_header]

    "/media"
    |> WhatsappApiRequestMedia.post!(data, headers)
    |> @parser.parse(:media_upload)
  end

  @doc """
  Obtiene el archivo media del servidor de la aplicación de Whatsapp
  """
  @spec download(MediaDownload.t(), tuple()) :: tuple
  def download(%MediaDownload{} = media, auth_header) do
    # Se envia no_parse: true para que no intente convertir la respuesta a JSON
    media_response =
      "/media/#{media.id}"
      |> WhatsappApiRequestMedia.get!(nil, [auth_header])
      |> @parser.parse(:media_download)

    {:ok, path} = Briefly.create(extname: ".#{media.extension}")
    File.write!(path, media_response)
    {:ok, path}
  end
end
