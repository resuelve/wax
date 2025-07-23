defmodule Wax.Messages.Interactive.Action do
  @doc """
  Interactive Actions struct
  """

  alias Wax.Messages.Interactive

  @type t :: %__MODULE__{
          interactive_type: Interactive.type(),
          button: String.t(),
          buttons: [Button.t()],
          catalog_id: String.t(),
          product_retailer_id: String.t(),
          sections: [Section.t()],
          name: String.t(),
          parameters: String.t()
        }

  defstruct [
    :interactive_type,
    :button,
    :buttons,
    :catalog_id,
    :product_retailer_id,
    :sections,
    :name,
    :parameters
  ]

  defimpl Jason.Encoder do
    def encode(value, opts) do
      fields =
        case Map.get(value, :interactive_type) do
          :button ->
            [:buttons]

          :list ->
            [:button, :sections]

          :product ->
            [:catalog_id, :product_retailer_id]

          :product_list ->
            [:catalog_id, :product_retailer_id, :sections]

          :flow ->
            [:name, :parameters]
        end

      value
      |> Map.take(fields)
      |> Jason.Encode.map(opts)
    end
  end
end
