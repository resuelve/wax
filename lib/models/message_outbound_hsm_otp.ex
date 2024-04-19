defmodule Whatsapp.Models.MessageOutboundHsmOtp do
  @moduledoc """
  Estructura del mensaje de autenticación OTP Whatsapp HSM
  """

  require Logger
  alias __MODULE__

  @enforce_keys [:to, :language_policy, :params, :components]

  defstruct(
    to: nil,
    namespace: nil,
    name: nil,
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
  @spec _validate_policy(MessageOutboundHsmOtp.t()) :: String.t()
  defp _validate_policy(%MessageOutboundHsmOtp{language_policy: language_policy} = msg)
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
      to: message.to,
      type: "template",
      template: %{
        name: message.name,
        language: %{
          policy: message.language_policy,
          code: message.language_code
        },
        category: "authentication",
        components: component_params(message) ++ message.components
      }
    }
  end

  defp component_params(message) do
    if message.components != nil do
      [
        %{
          type: "body",
          parameters: _format_params(message.params),
          add_security_recommendation: true
        },
        %{
          type: "footer"
        }
      ]
    else
      [
        %{
          type: "body",
          parameters: _format_params(message.params),
          add_security_recommendation: true
        },
        %{
          type: "buttons",
          buttons: [
            message.components
          ]
        }
      ]
    end
  end
end
