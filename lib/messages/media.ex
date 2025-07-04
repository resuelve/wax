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
          type: media_type()
        }

  defstruct [
    :id,
    :caption,
    :type
  ]

  defimpl Jason.Encoder do
    def encode(value, opts) do
      fields =
        case Map.get(value, :type) do
          :audio -> [:id]
          :image -> [:id, :caption]
          :video -> [:id, :caption]
          _ -> [:id]
        end

      value
      |> Map.take(fields)
      |> Jason.Encode.map(opts)
    end
  end
end
