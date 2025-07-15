defmodule Wax.Messages.Media do
  @moduledoc """
  The Whatsapp Message Media Object

  ## Fields

  - id: The media object ID
  - caption: Media asset caption. Doesn't apply for audio or stickers
  - filename: Describes the filename for the specific document

  """

  @type media_id :: String.t()

  @type media_type :: :audio | :document | :image | :video

  @type t :: %__MODULE__{
          id: media_id(),
          caption: String.t(),
          type: media_type(),
          filename: String.t()
        }

  defstruct [
    :id,
    :caption,
    :type,
    :filename
  ]

  defimpl Jason.Encoder do
    def encode(value, opts) do
      fields =
        case Map.get(value, :type) do
          :audio -> [:id]
          :document -> [:id, :caption, :filename]
          :image -> [:id, :caption]
          :video -> [:id, :caption]
          _ -> [:id]
        end

      value
      |> Map.take(fields)
      |> Jason.Encode.map(opts)
    end
  end

  @doc """
  Creates a new Media object of Image type
  """
  @spec new_image(String.t(), String.t()) :: __MODULE__.t()
  def new_image(media_id, caption \\ nil) do
    %__MODULE__{type: :image, id: media_id, caption: caption}
  end
end
