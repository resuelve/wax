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

  @doc """
  Creates a Auth struct

  This is required to interact with the Whatsapp Cloud API
  """
  @spec new(String.t(), String.t()) :: __MODULE__.t()
  def new(whatsapp_number_id, token) do
    %__MODULE__{
      whatsapp_number_id: whatsapp_number_id,
      token: token
    }
  end
end
