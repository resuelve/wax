defmodule Whatsapp.Models.MessageOutboundHsm do
  @moduledoc """
  Estructura del mensaje de Whatsapp HSM
  """

  require Logger
  alias __MODULE__

  @enforce_keys [:to, :language_policy, :params]

  defstruct(
    to: nil,
    namespace: nil,
    element_name: nil,
    language_policy: nil,
    language_code: nil,
    params: nil,
    params_header: nil
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
  @spec _validate_policy(MessageOutboundHsm.t()) :: String.t()
  defp _validate_policy(%MessageOutboundHsm{language_policy: language_policy} = msg)
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
  @spec format_params([String.t()]) :: [map]
  defp format_params(params) do
    Enum.map(params, fn param ->
      %{
        text: param,
        type: "text"
      }
    end)
  end

  def to_json(%__MODULE__{} = message) do
    %{
      recipient_type: "individual",
      to: message.to,
      type: "template",
      template: %{
        components: component_params(message),
        language: %{
          code: message.language_code,
          policy: message.language_policy
        },
        name: message.element_name,
        namespace: message.namespace
      }
    }
  end

  defp component_params(message) do
    if message.params_header != [] && message.params_header != nil do
      [
        %{
          parameters: format_params(message.params_header),
          type: "header"
        },
        %{
          parameters: format_params(message.params),
          type: "body"
        }
      ]
    else
      [
        %{
          parameters: format_params(message.params),
          type: "body"
        }
      ]
    end
  end
end
