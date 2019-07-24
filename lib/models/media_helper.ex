defmodule Whatsapp.Models.MediaHelper do
  @moduledoc """
  Helper para archivos media
  """

  @image_types ["jpg", "jpeg", "png"]
  @audio_types ["aac", "m4a", "amr", "mp3", "ogg", "opus"]
  @document_types ["pdf", "doc", "ppt", "xls", "docx", "pptx", "xlsx"]

  @doc """
  Valida que una extensión sea de un archivo válido para Whatsapp
  """
  @spec valid_extension?(String.t()) :: boolean
  def valid_extension?(filename) do
    case get_filename_data(filename) do
      {_name, extension} ->
        String.downcase(extension) in (@image_types ++ @audio_types ++ @document_types)

      _ ->
        false
    end
  end

  @doc """
  Obtiene el tipo del mensaje de la extensión del archivo
  """
  @spec get_type_from_extension(String.t() | nil) :: {String.t(), String.t()} | nil
  def get_type_from_extension(nil), do: nil

  def get_type_from_extension(filename) do
    case get_filename_data(filename) do
      {_name, file_extension} ->
        type =
          cond do
            file_extension in @image_types -> "image"
            file_extension in @audio_types -> "audio"
            file_extension in @document_types -> "document"
            true -> nil
          end

        {type, file_extension}

      _ ->
        nil
    end
  end

  @doc """
  Extrae el nombre y extensión de un archivo
  """
  @spec get_filename_data(String.t()) :: {String.t(), String.t()} | nil
  def get_filename_data(filename) do
    case Regex.run(~r/(.+)\.([^.]+)/, filename) do
      [_, name, extension] when is_binary(name) and is_binary(extension) ->
        {name, extension}

      _ ->
        nil
    end
  end

  @doc """
  Regresa el nombre del archivo si existe. Si no, se genera un UUID como nombre
  """
  @spec get_media_name(any()) :: String.t()
  def get_media_name(%{"name" => name}) when name in ["", nil] do
    get_media_name(nil)
  end

  def get_media_name(%{"name" => name}) do
    name
  end

  def get_media_name(_) do
    Ecto.UUID.generate()
  end
end
