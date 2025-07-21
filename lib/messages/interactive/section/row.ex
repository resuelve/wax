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

  @max_id_length 200
  @max_title_length 24
  @max_description_length 72

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

  @doc """
  Validates that the Row struct follows the Cloud API requirements
  """
  @spec validate(__MODULE__.t()) :: :ok | {:error, String.t()}
  def validate(%__MODULE__{id: id, title: title, description: description}) do
    cond do
      title in [nil, ""] ->
        {:error, "Row title is required"}

      id in [nil, ""] ->
        {:error, "Row ID is required"}

      String.length(id) > @max_id_length ->
        {:error, "Row ID cannot be longer than #{@max_title_length} characters"}

      String.length(title) > @max_title_length ->
        {:error, "Row title cannot be longer than #{@max_title_length} characters"}

      String.length(description) > @max_description_length ->
        {:error, "Row description cannot be longer than #{@max_title_length} characters"}

      true ->
        :ok
    end
  end
end
