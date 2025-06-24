defmodule Wax.Messages.Text do
  @type t :: %__MODULE__{body: String.t(), preview_url: boolean()}

  @derive {Jason.Encoder, only: [:body, :preview_url]}
  defstruct [:body, :preview_url]
end
