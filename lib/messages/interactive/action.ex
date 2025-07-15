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
          flow_message_version: 3,
          flow_id: String.t(),
          flow_name: String.t(),
          flow_cta: String.t(),
          mode: String.t(),
          flow_token: String.t(),
          flow_action: String.t(),
          flow_action_payload: String.t()
        }

  defstruct [
    :interactive_type,
    :button,
    :buttons,
    :catalog_id,
    :product_retailer_id,
    :sections,
    {:flow_message_version, 3},
    :flow_id,
    :flow_name,
    :flow_cta,
    :mode,
    :flow_token,
    :flow_action,
    :flow_action_payload
  ]

  defimpl Jason.Encoder do
    def encode(value, opts) do
      fields =
        case Map.get(value, :interactive_type) do
          :button ->
            [:button, :buttons]

          :list ->
            [:sections]

          :product ->
            [:catalog_id, :product_retailer_id]

          :product_list ->
            [:catalog_id, :product_retailer_id, :sections]

          :flow ->
            [
              :flow_message_version,
              :flow_id,
              :flow_name,
              :flow_cta,
              :mode,
              :flow_token,
              :flow_action,
              :flow_action_payload
            ]
        end

      value
      |> Map.take(fields)
      |> Jason.Encode.map(opts)
    end
  end
end
