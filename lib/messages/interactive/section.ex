defmodule Wax.Messages.Interactive.Section do
  @doc """
  Interactive Actions sections struct
  """

  @type t :: %__MODULE__{
          product_items: [map()],
          rows: [map()],
          title: String.t()
        }

  @max_title_length 24
  @max_rows 10

  @derive Jason.Encoder
  defstruct [
    :product_items,
    {:rows, []},
    :title
  ]

  @doc """
  Creates a new Interactive Action Section object
  """
  @spec new :: __MODULE__.t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Sets the title for the Section
  """
  @spec put_title(Module.t(), String.t()) :: __MODULE__.t()
  def put_title(%__MODULE__{} = section, title) do
    if String.length(title) > @max_title_length do
      raise "A Section title cannot have more than 24 characters"
    end

    %{section | title: title}
  end

  @doc """
  Adds a row to the Section
  """
  @spec add_row(__MODULE__.t(), String.t(), String.t(), String.t()) :: __MODULE__.t()
  def add_row(%__MODULE__{rows: rows} = section, row_id, row_title, row_description \\ nil) do
    if Enum.count(rows) >= @max_rows do
      raise "A Section cannot have more than 10 rows"
    end

    row = %{
      id: row_id,
      title: row_title,
      description: row_description
    }

    %{section | rows: [row | rows]}
  end
end
