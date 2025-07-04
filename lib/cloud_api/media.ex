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
          {:ok, Media.media_id()} | {:error, String.t()}
  def upload(file_path, %Auth{} = auth) do
    with :ok <- validate_file(file_path) do
      do_upload(file_path, auth)
    end
  end

  @spec do_upload(Path.t(), Auth.t()) :: {:ok, Media.media_id()} | {:error, String.t()}
  defp do_upload(file_path, auth) do
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

  @spec validate_file(Path.t()) :: :ok | {:error, String.t()}
  defp validate_file(file_path) do
    with :ok <- validate_extension(file_path) do
      :ok
    end
  end

  @spec validate_extension(Path.t()) :: :ok | {:error, String.t()}
  defp validate_extension(file_path) do
    case Path.extname(file_path) do
      "" ->
        error =
          "File has no extension. Whatsapp requires a valid extension to process media files"

        {:error, error}

      _extension ->
        :ok
    end
  end
end
