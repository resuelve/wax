defmodule Wax.Messages.Message do
  @moduledoc """
  The Whatsapp message

  It defines a structure and main functions to work with it to modify
  the message to send
  """

  alias Wax.Messages.{
    Contact,
    Context,
    Interactive,
    Location,
    Media,
    Template,
    Text
  }

  @typep whatsapp_media_id :: String.t()

  @typep message_type ::
           :contact
           | :interactive
           | :location
           | :template
           | :text
           | Media.media_type()

  @typep whatsapp_id :: String.t()

  @type t :: %__MODULE__{
          audio: Media.t(),
          contacts: [Contact.t()],
          context: Context.t(),
          document: Media.t(),
          image: Media.t(),
          interactive: Interactive.t(),
          location: Location.t(),
          messaging_product: atom(),
          preview_url: boolean(),
          recipient_type: atom(),
          status: String.t(),
          template: Template.t(),
          text: Text.t(),
          to: whatsapp_id(),
          type: message_type(),
          video: Media.t()
        }

  @message_types [
    :audio,
    :contact,
    :document,
    :image,
    :interactive,
    :location,
    :template,
    :text,
    :video
  ]

  defstruct audio: nil,
            contacts: [],
            context: nil,
            document: nil,
            image: nil,
            interactive: nil,
            location: nil,
            messaging_product: :whatsapp,
            preview_url: false,
            recipient_type: :individual,
            status: nil,
            template: nil,
            text: nil,
            to: nil,
            type: :text,
            video: nil

  defimpl Jason.Encoder do
    @base_fields [:messaging_product, :recipient_type, :to, :type]

    def encode(value, opts) do
      fields = @base_fields

      fields =
        case Map.get(value, :type) do
          :audio -> [:audio | fields]
          :document -> [:document | fields]
          :image -> [:image | fields]
          :video -> [:video | fields]
          _ -> [:text | fields]
        end

      value
      |> Map.take(fields)
      |> Jason.Encode.map(opts)
    end
  end

  @doc """
    Creates a new Message structure
  """
  @spec new(whatsapp_id()) :: __MODULE__.t()
  def new(to) when is_binary(to) do
    to = String.replace(to, " ", "")

    %__MODULE__{to: to}
  end

  @spec set_type(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def set_type(%__MODULE__{} = message, type) when type in @message_types do
    %{message | type: type}
  end

  @doc """
  Adds a text object to the message
  """
  @spec set_text(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def set_text(%__MODULE__{} = message, body, preview_url \\ false) do
    text = %Text{body: body, preview_url: preview_url}
    %{message | text: text}
  end

  @doc """
  Adds an audio object to the message
  """
  @spec add_audio(__MODULE__.t(), whatsapp_media_id()) :: __MODULE__.t()
  def add_audio(%__MODULE__{} = message, media_id) do
    media = %Media{id: media_id, type: :audio}

    %{message | audio: media}
  end

  @doc """
  Adds a document object to the message
  """
  @spec add_document(__MODULE__.t(), whatsapp_media_id(), String.t(), String.t()) ::
          __MODULE__.t()
  def add_document(%__MODULE__{} = message, media_id, filename, caption \\ nil) do
    # TODO: Media token builder
    media = %Media{id: media_id, type: :document, filename: filename, caption: caption}

    %{message | document: media}
  end

  @doc """
  Adds an image object to the message

  Images also accept a text caption that can be added on the same message
  """
  @spec add_image(__MODULE__.t(), whatsapp_media_id(), String.t() | nil) :: __MODULE__.t()
  def add_image(%__MODULE__{} = message, media_id, caption \\ nil) do
    media = %Media{id: media_id, caption: caption, type: :image}

    %{message | image: media}
  end

  @doc """
  Adds a video object to the message

  Videos also accept a text caption that can be added on the same message
  """
  @spec add_video(__MODULE__.t(), whatsapp_media_id(), String.t() | nil) :: __MODULE__.t()
  def add_video(%__MODULE__{} = message, media_id, caption \\ nil) do
    media = %Media{id: media_id, caption: caption, type: :video}

    %{message | video: media}
  end

  @doc """
  Validates a message

  Checks if a message is valid to be sent to the Cloud API
  """
  @spec validate(__MODULE__.t()) :: :ok | {:error, String.t()}
  def validate(%__MODULE__{to: to}) when to in ["", nil] do
    {:error, "Missing recipient number of message"}
  end

  def validate(%__MODULE__{type: :text} = message) do
    case message.text do
      %Text{body: text_body} when text_body in ["", nil] ->
        {:error, "A text body is required when sending a text message"}

      %Text{} ->
        :ok

      _ ->
        {:error, "Text field is required"}
    end
  end

  def validate(%__MODULE__{type: :image} = message) do
    case message.image do
      %Media{id: id} when is_binary(id) ->
        :ok

      _ ->
        {:error, "Image field is required. Use add_image/3 to add_one"}
    end
  end

  def validate(%__MODULE__{type: :audio, audio: %Media{id: id}}) when is_binary(id) do
    :ok
  end

  def validate(%__MODULE__{type: :document, document: %Media{id: id, filename: filename}})
      when is_binary(id) do
    case Path.extname(filename) do
      "" -> {:error, "Document filename has no extension"}
      _extension -> :ok
    end
  end

  def validate(%__MODULE__{type: :video, video: %Media{id: id}}) when is_binary(id) do
    :ok
  end

  def validate(%__MODULE__{type: :audio}) do
    {:error, "Audio field is required. Use add_audio/3 to add one."}
  end

  def validate(%__MODULE__{type: :document}) do
    {:error, "Document field is required. Use add_document/3 to add one."}
  end

  def validate(%__MODULE__{type: :video}) do
    {:error, "Video field is required. Use add_video/3 to add one."}
  end

  def validate(%__MODULE__{type: type}) do
    {:error, "Unsupported message type: #{type}"}
  end
end
