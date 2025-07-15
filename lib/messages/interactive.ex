defmodule Wax.Messages.Interactive do
  @moduledoc """
  Interactive Messages

  ## Important

  Interactive messages of type `catalog_message` is not supported for lack
  of documentation on the Cloud API site. They can be added in the future.
  """

  alias Wax.Messages.Interactive.{Action, Header}

  @type type :: :button | :list | :product | :product_list | :flow

  @type t :: %__MODULE__{
          action: term(),
          body: map(),
          footer: map(),
          header: Header.t(),
          type: type()
        }

  @interactive_types [:button, :list, :product, :product_list, :flow]

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
  @spec new(type()) :: __MODULE__.t()
  def new(type) when type in @interactive_types do
    %__MODULE__{type: type}
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
  """
  @spec put_footer(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def put_footer(%__MODULE__{} = interactive, content) when is_binary(content) do
    footer = %{text: content}

    %{interactive | footer: footer}
  end

  @doc """
  Adds a list of buttons to the Interactive message

  The `buttons` paramater is expected to be a list of strings where each element
  will be the title (content) of the button.

  """
  @spec put_button_action(__MODULE__.t(), [button_title :: String.t()]) :: __MODULE__.t()
  def put_button_action(%__MODULE__{} = interactive, [_ | _] = buttons) do
    buttons =
      buttons
      |> Enum.with_index()
      |> Enum.map(fn {button_title, index} ->
        %{type: :reply, reply: %{title: button_title, id: index}}
      end)

    action = %Action{interactive_type: interactive.type, buttons: buttons}
    %{interactive | action: action}
  end
end
