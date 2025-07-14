defmodule Wax.Messages.Templates.Component do
  @moduledoc """
  Template Components structure and management
  """

  alias Wax.Messages.Templates.{ButtonParameter, Parameter}

  @type component_type :: :header | :body | :button
  @type button_type :: :catalog | :quick_reply | :url

  @type t :: %__MODULE__{
          type: component_type(),
          sub_type: button_type(),
          parameters: [Parameter.t()],
          index: 0..9
        }

  @valid_button_types [:quick_reply, :url, :catalog]

  @derive {Jason.Encoder, only: [:type, :sub_type, :parameters, :index]}
  defstruct [
    :type,
    :sub_type,
    {:parameters, []},
    :index
  ]

  @doc """
  Creats a new Header Component struct
  """
  @spec new_header([Parameter.t()]) :: __MODULE__.t()
  def new_header(params) do
    %__MODULE__{type: :header, parameters: params}
  end

  @doc """
  Creats a new Body Component struct
  """
  @spec new_body([Parameter.t()]) :: __MODULE__.t()
  def new_body(params) do
    %__MODULE__{type: :body, parameters: params}
  end

  @doc """
  Creats a new Button Component struct
  """
  @spec new_button(button_type(), 0..9, [Parameter.t()]) :: __MODULE__.t()
  def new_button(sub_type, index, params) when sub_type in @valid_button_types do
    %__MODULE__{type: :button, sub_type: sub_type, index: index, parameters: params}
  end

  @doc """
  Validates that the button parameters follow the rules and
  constraints of the Cloud API
  """
  @spec validate_button_params(button_type(), Keyword.t()) ::
          :ok | {:error, String.t()}
  def validate_button_params(:catalog, _params) do
    {:error, "Catalog type parameter not supported"}
  end

  def validate_button_params(:quick_reply, [_ | _] = params) do
    do_validate(params, [:payload])
  end

  def validate_button_params(:url, [_ | _] = params) do
    do_validate(params, [:text])
  end

  @spec do_validate(Keyword.t(), [atom()]) :: :ok | {:error, String.t()}
  defp do_validate(params, required_params) do
    with :ok <- validate_required(params, required_params),
         nil <- find_error_in_params(params) do
      :ok
    end
  end

  @spec validate_required(Keyword.t(), [atom()]) :: :ok | {:error, String.t()}
  defp validate_required(params, required_params) do
    all_params_exists? =
      Enum.all?(required_params, fn required_param ->
        Enum.any?(params, fn {param_name, _} -> param_name == required_param end)
      end)

    if all_params_exists? do
      :ok
    else
      {:error, "Missing required parameters"}
    end
  end

  @spec find_error_in_params(Keyword.t()) :: nil | {:error, String.t()}
  defp find_error_in_params(params) do
    Enum.find_value(params, fn param ->
      case ButtonParameter.validate(param) do
        {:error, error} -> {:error, error}
        _ -> false
      end
    end)
  end
end
