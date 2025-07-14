defmodule Wax.Messages.Templates.ButtonParameter do
  @moduledoc """
  Template button parameter struct
  """

  @typep parameter_type :: :payload | :text
  @type t :: %__MODULE__{
          type: parameter_type(),
          payload: String.t() | map(),
          text: String.t()
        }

  @derive {Jason.Encoder, only: [:type, :payload, :text]}
  defstruct [
    :type,
    :payload,
    :text
  ]

  @doc """
  Converts a keyword list of parameters to a list of structs
  """
  @spec parse(Keyword.t()) :: [__MODULE__.t()]
  def parse([_ | _] = params) do
    Enum.reduce_while(params, [], fn param, acc ->
      case parse(param) do
        %__MODULE__{} = parsed_param ->
          {:cont, [parsed_param | acc]}

        {:invalid_param, invalid_param} ->
          {:halt, {:error, "Invalid button param: #{inspect(invalid_param)}"}}
      end
    end)
  end

  def parse({:payload, payload}) when is_binary(payload) or is_map(payload) do
    %__MODULE__{type: :payload, payload: payload}
  end

  def parse({:text, text}) when is_binary(text) do
    %__MODULE__{type: :text, text: text}
  end

  def parse(param) do
    {:invalid_param, param}
  end

  @doc """
  Validates parameter data
  """
  @spec validate({atom(), term()}) :: :ok | {:error, String.t()}
  def validate({:payload, payload}) when is_binary(payload) or is_map(payload) do
    :ok
  end

  def validate({:text, text}) when is_binary(text) do
    :ok
  end
end
