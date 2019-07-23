defmodule Whatsapp.Api.Media do
  @moduledoc """
  Modulo para el manejo de archivos media de Whatsapp
  """

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

    with {:ok, media_result} <- WhatsappApiRequestMedia.post("media", data, headers) do
      %{"media" => [%{"id" => media_id}]} = media_result
      Logger.info(fn -> "Media #{media_id} uploaded correctly" end)
      {:ok, media_id}
    else
      error ->
        {:error, error}
    end
  end

  @doc """
  Obtiene el archivo media del servidor de la aplicación de Whatsapp
  """
  @spec download(MediaDownload.t(), tuple()) :: tuple
  def download(%MediaDownload{} = media, auth_header) do
    # Se envia no_parse: true para que no intente convertir la respuesta a JSON
    case WhatsappApiRequestMedia.get("media/#{media.id}", [auth_header]) do
      {:ok, media_response} when is_bitstring(media_response) ->
        {:ok, path} = Briefly.create(extname: ".#{media.extension}")
        File.write!(path, media_response)
        {:ok, path}

      _ ->
        {:error, "Response media data was not found"}
    end
  end
end
