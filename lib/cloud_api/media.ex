defmodule Wax.CloudAPI.Media do
  @moduledoc """
  Media managment via the Cloud API
  """

  alias Wax.CloudAPI
  alias Wax.CloudAPI.{Auth, ResponseParser}

  @doc """
  Uploads an image to the Cloud API servers from the given path

  This returns the Media ID, which is required to send any type
  of media files in a message.

  """
  @spec upload_from_path(Path.t(), Auth.t()) ::
          {:ok, Media.media_id()} | {:error, String.t()}
  def upload_from_path(file_path, %Auth{} = auth) do
    upload(file_path, file_path, auth)
  end

  @doc """
  Uploads an image to the Cloud API servers from binary data

  This returns the Media ID, which is required to send any type
  of media files in a message.

  """
  @spec upload_binary(iodata(), String.t(), Auth.t()) ::
          {:ok, Media.media_id()} | {:error, String.t()}
  def upload_binary(binary_file_content, filename, %Auth{} = auth) do
    upload(binary_file_content, filename, auth)
  end

  @spec upload(Path.t() | iodata(), Path.t(), Auth.t()) ::
          {:ok, Media.media_id()} | {:error, String.t()}
  defp upload(multipart_data, file_path, auth) do
    # with :ok <- validate_file(file_path) do
    #   mime_type = detect_mime(file_path)
    #   filename = Path.basename(file_path)

    #   do_upload(multipart_data, mime_type, filename, auth)
    # end
    with :ok <- validate_file(file_path),
      {:ok, mime_type} <- detect_mime(file_path) do
      filename = Path.basename(file_path)

      do_upload(multipart_data, mime_type, filename, auth)

    end
  end

  @spec do_upload(Path.t() | iodata(), String.t(), String.t(), Auth.t()) ::
          {:ok, Media.media_id()} | {:error, String.t()}
  defp do_upload(multipart_data, mime_type, filename, auth) do
    headers = [Auth.build_header(auth)]

    data = [
      {"file", multipart_data, {"form-data", [name: "file", filename: filename]},
       [{"Content-Type", mime_type}]},
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

  @spec detect_mime(Path.t()) :: String.t()
  defp detect_mime(file_path) do
    case Path.extname(file_path) do
      ".m4a" -> {:ok, "audio/mp4"}
    ".ogg" -> {:ok, "audio/ogg"}
    ".mp3" -> {:ok, "audio/mpeg"}
    ".aac" -> {:ok, "audio/aac"}
    ".amr" -> {:ok, "audio/amr"}
    ".opus" -> {:ok, "audio/opus"}
    ".pdf" -> {:ok, "application/pdf"}
    ".doc" -> {:ok, "application/msword"}
    ".docx" -> {:ok, "application/vnd.openxmlformats-officedocument.wordprocessingml.document"}
    ".ppt" -> {:ok, "application/vnd.ms-powerpoint"}
    ".pptx" -> {:ok, "application/vnd.openxmlformats-officedocument.presentationml.presentation"}
    ".xls" -> {:ok, "application/vnd.ms-excel"}
    ".xlsx" -> {:ok, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"}
    ".txt" -> {:ok, "text/plain"}
    ".jpeg" -> {:ok, "image/jpeg"}
    ".jpg" -> {:ok, "image/jpeg"}
    ".png" -> {:ok, "image/png"}
    ".webp" -> {:ok, "image/webp"}
    ".mp4" -> {:ok, "video/mp4"}
    ".3gp" -> {:ok, "video/3gpp"}
    extension -> {:error, "File #{extension} not supported"}
    end
  end
end
