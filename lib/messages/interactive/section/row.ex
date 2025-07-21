defmodule Wax.Messages.Interactive.Section.Row do
  @moduledoc """
  A Section Row struct

  It is used in Interactive type messages
  """

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          description: String.t()
        }

  @enforce_keys [:id, :title]
  defstruct [
    :id,
    :title,
    :description
  ]

  @doc """
  Creates a new section row object
  """
  @spec new(String.t(), String.t(), String.t()) :: __MODULE__.t()
  def new(id, title, description \\ nil) do
    %__MODULE__{id: id, title: title, description: description}
  end
end
