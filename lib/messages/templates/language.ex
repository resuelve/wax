defmodule Wax.Messages.Templates.Language do
  @moduledoc """
    Defines the Template language structure

    code: Is the language code in either `language` (en) or `language_locale` (en_ES) formats
    policy: This is always "deterministic"

  """

  @type t :: %__MODULE__{
          code: String.t(),
          policy: String.t()
        }

  @derive {Jason.Encoder, only: [:code, :policy]}
  @enforce_keys [:code, :policy]
  defstruct [:code, :policy]

  @doc """
  Creates a new language struct
  """
  @spec new(String.t()) :: __MODULE__.t()
  def new(code) do
    %__MODULE__{
      code: code,
      policy: "deterministic"
    }
  end
end
