defmodule Whatsapp.Models.MessageOutboundMedia do
  @moduledoc """
  Estructura del mensaje de Whatsapp
  """

  require Logger
  alias __MODULE__

  @enforce_keys [:to, :type, :data, :file_name]

  defstruct(
    to: nil,
    type: nil,
    file_name: nil,
    caption: nil,
    mime_type: nil,
    data: nil,
    extension: nil,
    media_id: nil
  )

  @type t :: %__MODULE__{}

  @doc """
  Crea un mensaje nuevo
  """
  @spec new(Keyword.t()) :: __MODULE__.t()
  def new(options) do
    attrs =
      options
      |> Enum.into(Map.new)
      |> _add_extension_from_mime()
      |> _add_caption()
      |> _add_binary_data()

    Kernel.struct(__MODULE__, attrs)
  end

  def set_medial_id(media, media_id) do
    %{media | media_id: media_id}
  end

  def validate(%MessageOutboundMedia{media_id: nil}) do
    {:error, "Invalid media_id"}
  end
  def validate(message) do
    {:ok, message}
  end

  def to_json(%__MODULE__{} = message) do
    %{
      recipient_type: "individual",
      to: message.to,
      type: message.type,
      "#{message.type}": media_to_json(message)
    }
  end

  # Genera la estructura del archivo media.
  # No se envía caption si el tipo de archivo es audio o si es nulo
  @spec media_to_json(__MODULE__.t()) :: map
  defp media_to_json(%__MODULE__{type: "audio", media_id: media_id}) do
    %{id: media_id}
  end

  defp media_to_json(%__MODULE__{caption: nil, media_id: media_id}) do
    %{id: media_id}
  end

  defp media_to_json(%__MODULE__{caption: caption, media_id: media_id}) do
    %{
      id: media_id,
      caption: caption
    }
  end

  @doc """
  Agrega el binario del archivo media al campo de data
  """
  @spec _add_binary_data(__MODULE__.t()) :: __MODULE__.t()
  def _add_binary_data(%__MODULE__{data: binary_data} = msg) when is_bitstring(binary_data) do
    binary_data =
      if String.starts_with?(binary_data, "data:") do
        [_, binary_data] = String.split(binary_data, ",", parts: 2)
        binary_data
      else
        binary_data
      end

    %{msg | data: Base.decode64!(binary_data)}
  end

  # Obtiene la extension del archivo a partir del mime_type
  # El null (o vacío) a PDF es por un bug de Whatsapp
  @spec _add_extension_from_mime(map()) :: map()
  defp _add_extension_from_mime(%{mime_type: nil} = msg) do
    Map.put(msg, :extension, "pdf")
  end

  defp _add_extension_from_mime(%{mime_type: mime_type} = msg) do
    [_, extension] = Regex.run(~r/\/([a-z0-9]+)/, mime_type)
    Map.put(msg, :extension, extension)
  end

  defp _add_extension_from_mime(msg) do
    Map.put(msg, :extension, "pdf")
  end

  # Asigna el nombre del archivo como content para los mensajes media de tipo document
  @spec _add_caption(map()) :: map()
  def _add_caption(%{caption: caption, type: "document", file_name: file_name} = msg) when caption in [nil, ""] do
    Map.put(msg, :caption, file_name)
  end

  def _add_caption(%{caption: caption, type: "document", extension: extension} = msg) do
    Map.put(msg, :caption, caption <> "." <> extension)
  end

  def _add_caption(%{caption: caption} = msg) do
    Map.put(msg, :caption, caption)
  end

  def _add_caption(_) do
    {:error, "Invalid caption"}
  end
end
