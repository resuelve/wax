defmodule Wax.CloudAPI.Media do
  @moduledoc """
  Media managment via the Cloud API
  """

  alias Wax.CloudAPI
  alias Wax.CloudAPI.{Auth, ResponseParser}

  @doc """
  Uploads an image to the Cloud API servers

  This returns the Media ID, which is required to send any type
  of media files in a message.

  """
  @spec upload(Path.t(), Auth.t()) ::
          {:ok, media_id :: String.t()} | {:error, String.t()}
  def upload(file_path, %Auth{} = auth) do
    mime_type = MIME.from_path(file_path)
    headers = [Auth.build_header(auth)]

    data = [
      {:file, file_path},
      {"type", mime_type},
      {"messaging_product", "whatsapp"}
    ]

    auth.whatsapp_number_id
    |> CloudAPI.build_url("media")
    |> HTTPoison.post({:multipart, data}, headers)
    |> case do
      {:ok, response} ->
        ResponseParser.parse(response, :media_upload)

      _ ->
        {:error, "Media upload failed"}
    end
  end
end
