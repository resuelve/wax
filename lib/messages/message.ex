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

  @message_types [:contact, :document, :image, :interactive, :location, :template, :text]

  @typep whatsapp_media_id :: String.t()

  @typep message_type ::
           :contact | :document | :image | :interactive | :location | :template | :text

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
          type: message_type()
        }

  @fields_to_encode [
    :audio,
    :contacts,
    :context,
    :document,
    :image,
    :interactive,
    :location,
    :messaging_product,
    :preview_url,
    :recipient_type,
    :status,
    :template,
    :text,
    :to,
    :type
  ]
  @derive {Jason.Encoder, only: @fields_to_encode}
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
            type: :text

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
  Adds an image object to the message

  Images also accept a text caption to be sent together with it
  """
  @spec add_image(__MODULE__.t(), whatsapp_media_id(), String.t() | nil) :: __MODULE__.t()
  def add_image(%__MODULE__{} = message, media_id, caption \\ nil) do
    media = %Media{id: media_id, caption: caption}

    %{message | image: media}
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
        {:error, "Media field is required"}
    end
  end

  def validate(%__MODULE__{type: type}) do
    {:error, "Unsupported message type: #{type}"}
  end
end
