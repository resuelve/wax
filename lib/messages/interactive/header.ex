defmodule Wax.Messages.Interactive.Header do
  alias Wax.Messages.Media

  @type type :: :text | :document | :image | :video

  @type t :: %__MODULE__{
          document: Media.t(),
          image: Media.t(),
          text: String.t(),
          sub_text: String.t(),
          type: atom(),
          video: Media.t()
        }

  defstruct [
    :document,
    :image,
    :text,
    :sub_text,
    :type,
    :video
  ]

  defimpl Jason.Encoder do
    def encode(value, opts) do
      fields = [:sub_text, :type]

      fields =
        case Map.get(value, :type) do
          :document -> [:document | fields]
          :image -> [:image | fields]
          :video -> [:video | fields]
          :text -> [:text | fields]
        end

      value
      |> Map.take(fields)
      |> Jason.Encode.map(opts)
    end
  end

  @doc """
    Creates a new header

    Depending the type, it will require a binary content or a Media content

    Requires binary:
      - text

    Requires media:
      - document
      - image
      - video

  """
  @spec new_header(type(), String.t() | Media.t(), String.t()) :: __MODULE__.t()
  def new_header(:text, text, sub_text) when is_binary(text) do
    %__MODULE__{type: :text, text: text, sub_text: sub_text}
  end

  def new_header(:document, %Media{} = media, sub_text) do
    %__MODULE__{type: :document, document: media, sub_text: sub_text}
  end

  def new_header(:image, %Media{} = media, sub_text) do
    %__MODULE__{type: :image, image: media, sub_text: sub_text}
  end

  def new_header(:video, %Media{} = media, sub_text) do
    %__MODULE__{type: :video, video: media, sub_text: sub_text}
  end
end
