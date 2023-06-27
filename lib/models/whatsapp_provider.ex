defmodule Whatsapp.Models.WhatsappProvider do
  defstruct [:name, :url, :username, :password]

  @type t :: %__MODULE__{
          name: String.t(),
          password: String.t(),
          url: String.t(),
          username: String.t()
        }
end
