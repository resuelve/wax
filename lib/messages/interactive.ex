defmodule Wax.Messages.Interactive do
  @moduledoc """
  Interactive Messages

  ## Important

  Interactive messages of type `catalog_message` is not supported for lack
  of documentation on the Cloud API site. They can be added in the future.

  TODO: Implement multi-product interactive messages

  """

  alias Wax.Messages.Interactive.{Action, Header, Section}

  @type type :: :button | :list | :product | :product_list | :flow

  @type t :: %__MODULE__{
          action: term(),
          body: map(),
          footer: map(),
          header: Header.t(),
          type: type()
        }

  @optional_flow_params [:mode, :flow_token, :flow_action, :flow_action_payload]

  @max_interactive_buttons 3
  @max_length_action_button 20
  @max_length_cta_button 30
  @max_body_chars 1024
  @max_footer_chars 60
  @max_sections 10

  @derive Jason.Encoder
  defstruct [
    :action,
    :body,
    :footer,
    :header,
    :type
  ]

  @doc """
  Creates a new interactive object
  """
  @spec new() :: __MODULE__.t()
  def new() do
    %__MODULE__{}
  end

  @doc """
  Sets the header of the Interactive message
  """
  @spec put_header(__MODULE__.t(), Header.type(), String.t() | Media.t(), String.t() | nil) ::
          __MODULE__.t()
  def put_header(%__MODULE__{} = interactive, type, content, sub_text \\ nil) do
    header = Header.new_header(type, content, sub_text)

    %{interactive | header: header}
  end

  @doc """
  Sets the body of the Interactive message
  """
  @spec put_body(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def put_body(%__MODULE__{} = interactive, content) when is_binary(content) do
    body = %{text: content}

    %{interactive | body: body}
  end

  @doc """
  Sets the footer of the Interactive message

  The footer content cannot be more than 60 characters

  """
  @spec put_footer(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def put_footer(%__MODULE__{} = interactive, content) when is_binary(content) do
    footer = %{text: content}

    %{interactive | footer: footer}
  end

  @doc """
  Adds a list of buttons to the Interactive message

  The `buttons` argument is expected to be a list of strings where each element
  will be the title (content) of the button.

  A max of 3 buttons can be sent.

  """
  @spec put_button_action(__MODULE__.t(), [button_title :: String.t()]) :: __MODULE__.t()
  def put_button_action(%__MODULE__{} = interactive, [_ | _] = buttons) do
    buttons =
      buttons
      |> Enum.with_index()
      |> Enum.map(fn {button_title, index} ->
        %{type: :reply, reply: %{title: button_title, id: index}}
      end)

    action = %Action{interactive_type: :button, buttons: buttons}
    %{interactive | type: :button, action: action}
  end

  @doc """
  Adds a list to the Interactive message

  The `sections` argument requires a list of %Section{} structs that can be constructed
  using the Wax.Messages.Interactive.Section module

  """
  def put_list_action(%__MODULE__{} = interactive, button_text, [%Section{} | _] = sections) do
    action = %Action{interactive_type: :list, button: button_text, sections: sections}

    %{interactive | type: :list, action: action}
  end

  @doc """
  Adds a product to the Interactive message

  The product ID has to be a valid ID from your catalog only containing digits.

  """
  @spec put_product_action(__MODULE__.t(), String.t(), String.t()) :: __MODULE__.t()
  def put_product_action(%__MODULE__{} = interactive, catalog_id, product_retailer_id)
      when is_binary(catalog_id) and is_binary(product_retailer_id) do
    action = %Action{
      interactive_type: :product,
      catalog_id: catalog_id,
      product_retailer_id: product_retailer_id
    }

    %{interactive | type: :product, action: action}
  end

  @doc """
  Sets the message action to a Flow

  ## Note on Flow type messages

  As for 2025-07-21 the Whatsapp Cloud API documentation says all fields for Flow messages
  appear directly on the Action object and this is incorrect as it can be seen on the examples
  of the same documentation.

  This is the example given:

  ```
  curl -X  POST \
  'https://graph.facebook.com/v23.0/FROM_PHONE_NUMBER/messages' \
  -H 'Authorization: Bearer ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
   "messaging_product": "whatsapp",
   "recipient_type": "individual",
   "to": "PHONE_NUMBER",
   "type": "interactive",
   "interactive" : {
    "type": "flow",
    "header": {
      "type": "text",
      "text": "Flow message header"
    },
    "body": {
      "text": "Flow message body"
    },
    "footer": {
      "text": "Flow message footer"
    },
    "action": {
      "name": "flow",
      "parameters": {
        "flow_message_version": "3",
        "flow_id": "<FLOW_ID>", // Or flow_name
        "flow_cta": "Book!",
       }
      }
     }
    }
  }'
  ```

  These fields have to be sent between:
  - `name`: The only thing that appears on the docs about this field is an example with a fixed string "flow"
  - `parameters`: Here is where the flow ID, name and other values have to be sent

  """
  @spec put_flow_action(__MODULE__.t(), String.t(), {:id | :name, String.t()}, map()) ::
          __MODULE__.t()
  def put_flow_action(
        %__MODULE__{} = interactive,
        flow_cta,
        {_, _} = flow_identifier,
        optional_params \\ %{}
      ) do
    action = %Action{
      interactive_type: :flow,
      name: "flow",
      parameters: %{
        flow_message_version: "3",
        flow_cta: flow_cta
      }
    }

    action =
      action
      |> add_flow_identifier(flow_identifier)
      |> add_optional_params(optional_params)

    %{interactive | type: :flow, action: action}
  end

  @spec add_flow_identifier(Action.t(), {:id | :name, String.t()}) :: Action.t()
  defp add_flow_identifier(%Action{parameters: parameters} = action, {:id, id}) do
    updated_parameters = Map.put(parameters, :flow_id, id)
    %{action | parameters: updated_parameters}
  end

  defp add_flow_identifier(%Action{parameters: parameters} = action, {:name, name}) do
    updated_parameters = Map.put(parameters, :flow_name, name)
    %{action | parameters: updated_parameters}
  end

  @spec add_optional_params(Action.t(), map()) :: Action.t()
  defp add_optional_params(%Action{parameters: parameters} = action, optional_params) do
    updated_parameters =
      optional_params
      |> Map.take(@optional_flow_params)
      |> Map.merge(parameters)

    %{action | parameters: updated_parameters}
  end

  @doc """
  Validates an Interactive struct
  """
  @spec validate(__MODULE__.t()) :: :ok | {:error, String.t()}
  def validate(%__MODULE__{body: body, footer: footer} = interactive) do
    valid_body? =
      case {interactive.type, body} do
        {:product, %{text: text}} ->
          is_binary(text) and String.length(text) < @max_body_chars

        {:product, _} ->
          true

        {_, %{text: text}} ->
          body_size = (is_binary(text) && String.length(text)) || 0
          body_size > 0 and body_size < @max_body_chars

        _ ->
          false
      end

    valid_footer? =
      case footer do
        %{text: footer_text} ->
          footer_size = (is_binary(footer_text) && String.length(footer_text)) || 0
          footer_size > 0 and footer_size < @max_body_chars

        nil ->
          true
      end

    case {valid_body?, valid_footer?} do
      {false, _} ->
        "Invalid body content size. This field is required and cannot be longer than #{@max_body_chars}"

      {_, false} ->
        "Invalid footer content size. This field is required and cannot be longer than #{@max_footer_chars}"

      _ ->
        do_validate(interactive)
    end
  end

  @spec do_validate(__MODULE__.t()) :: :ok | {:error, String.t()}
  defp do_validate(%__MODULE__{type: :button, action: %Action{buttons: buttons}}) do
    if length(buttons) <= @max_interactive_buttons do
      :ok
    else
      error =
        "An interactive button type message cannot have more than #{@max_interactive_buttons} buttons"

      {:error, error}
    end
  end

  defp do_validate(%__MODULE__{type: :list, action: %Action{} = action}) do
    button_text_length = String.length(action.button)
    total_sections = Enum.count(action.sections)

    case {button_text_length, total_sections} do
      {0, _} ->
        {:error, "The button text is required for list messages"}

      {_, 0} ->
        {:error, "At least one section is required for list messages"}

      {_, total_sections} when total_sections > @max_sections ->
        {:error, "A list message cannot have more than #{@max_sections} sections"}

      {button_total_characters, _} when button_total_characters > @max_length_action_button ->
        {:error, "A list button cannot have more than #{@max_length_action_button} characters"}

      _ ->
        action.sections
        |> Enum.map(&Section.validate/1)
        |> Enum.find(fn
          :ok -> false
          {:error, _} -> true
        end)
        |> case do
          nil -> :ok
          {:error, error} -> {:error, error}
        end
    end
  end

  defp do_validate(%__MODULE__{
         type: :product,
         action: %Action{catalog_id: catalog_id, product_retailer_id: product_retailer_id}
       }) do
    valid_catalog_id? = is_binary(catalog_id) && catalog_id not in ["", nil]

    valid_product_retailer_id? =
      is_binary(product_retailer_id) && product_retailer_id not in ["", nil]

    case {valid_catalog_id?, valid_product_retailer_id?} do
      {false, _} -> {:error, "Invalid Catalog ID"}
      {_, false} -> {:error, "Invalid Product Retailer ID"}
      _ -> :ok
    end
  end

  defp do_validate(%__MODULE__{
         type: :flow,
         action: %Action{name: name, parameters: parameters}
       })
       when is_binary(name) and is_map(parameters) do
    id_fields = [:flow_name, :flow_id]

    has_some_id? =
      Enum.any?(id_fields, fn identifier ->
        case Map.get(parameters, identifier) do
          identifier when is_binary(identifier) and identifier not in ["", nil] ->
            true

          _ ->
            false
        end
      end)

    valid_cta? =
      case String.length(parameters[:flow_cta]) do
        0 ->
          false

        total_characters when total_characters > @max_length_cta_button ->
          false

        _ ->
          true
      end

    case {has_some_id?, valid_cta?} do
      {false, _} -> {:error, "Missing Flow identifier. Requires either a flow_id or flow_name"}
      {_, false} -> {:error, "Invalid CTA"}
      _ -> :ok
    end
  end

  defp do_validate(%__MODULE__{
         type: :flow,
         action: %Action{}
       }) do
    {:error, "Invalid Flow action"}
  end

  defp do_validate(%__MODULE__{action: _action}) do
    {:error, "Interactive messages should have an action object"}
  end
end
