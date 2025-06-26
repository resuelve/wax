defmodule Wax.Messages.Media do
  @moduledoc """
  The Whatsapp Message Media Object

  ## Fields

  - id: The media object ID
  - link: The protocol and URL of the media to be sent
  - caption: Media asset caption
  - filename: Describes the filename for the specific document

  """

  @type t :: %__MODULE__{
          id: String.t(),
          caption: String.t()
        }

  @fields_to_encode ~w(id caption)a

  @derive {Jason.Encoder, only: @fields_to_encode}
  defstruct [
    :id,
    :caption
  ]
end
