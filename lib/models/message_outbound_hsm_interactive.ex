defmodule Whatsapp.Models.MessageOutboundHsmInteractive do
  @moduledoc """
  Estructura del mensaje de Whatsapp HSM Interactive
  """

  require Logger
  alias __MODULE__

  @enforce_keys [:to, :language_policy, :params, :components]

  defstruct(
    to: nil,
    namespace: nil,
    element_name: nil,
    language_policy: nil,
    language_code: nil,
    params: nil,
    components: nil
  )

  @valid_language_policies ["deterministic"]

  @default_values %{
    language_policy: "deterministic",
    params: []
  }

  @type t :: %__MODULE__{}

  @doc """
  Crea un mensaje nuevo
  """
  @spec new(Keyword.t()) :: __MODULE__.t()
  def new(options) do
    attrs = Enum.into(options, Map.new())

    Kernel.struct(__MODULE__, Map.merge(@default_values, attrs))
  end

  # Valida que el tipo de selección de lenguaje sea válido
  @spec _validate_policy(MessageOutboundHsmInteractive.t()) :: String.t()
  defp _validate_policy(%MessageOutboundHsmInteractive{language_policy: language_policy} = msg)
       when language_policy in @valid_language_policies do
    {:ok, msg}
  end

  defp _validate_policy(_message), do: {:error, "Invalid language policy"}

  def validate(message) do
    with {:ok, message} <- _validate_policy(message) do
      {:ok, message}
    end
  end

  # Formatea la lista de parametros como parametros default para el HSM
  @spec _format_params([String.t()]) :: [map]
  def _format_params(params) when is_list(params) do
    Enum.map(params, &_convert_to_parameter/1)
  end

  def _convert_to_parameter(type, value, caption) do
    Map.new()
    |> Map.put(type, value)
    |> Map.put("caption", caption)
    |> _convert_to_parameter()
  end

  def _convert_to_parameter(text) when is_binary(text) do
    %{type: "text", text: text}
  end

  def _convert_to_parameter(%{"text" => replacement_text}) do
    %{type: "text", text: replacement_text}
  end

  def to_json(%__MODULE__{} = message) do
    %{
      recipient_type: "individual",
      to: message.to,
      type: "template",
      template: %{
        components:
          [
            %{
              type: "body",
              parameters: _format_params(message.params)
            }
          ] ++ message.components,
        language: %{
          code: message.language_code,
          policy: message.language_policy
        },
        name: message.element_name,
        namespace: message.namespace
      }
    }
  end
end
