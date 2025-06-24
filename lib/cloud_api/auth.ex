defmodule Wax.CloudAPI.Auth do
  @moduledoc """
  Manages the data required for Cloud API authentication
  """

  @type t :: %__MODULE__{
          whatsapp_number_id: String.t(),
          token: String.t()
        }

  defstruct [
    :whatsapp_number_id,
    :token
  ]
end
