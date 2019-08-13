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
    params: nil
  )

  @valid_language_policies ["deterministic", "fallback"]

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

  defp _validate_policy(message), do: {:error, "Invalid language policy"}

  def validate(message) do
    with {:ok, message} <- _validate_policy(message) do
      {:ok, message}
    end
  end

  # Formatea la lista de parametros como parametros default para el HSM
  @spec format_params([String.t()]) :: [map]
  defp format_params(params) do
    Enum.map(params, fn param -> %{default: param} end)
  end

  def to_json(%__MODULE__{} = message) do
    %{
      recipient_type: "individual",
      to: message.to,
      type: "hsm",
      hsm: %{
        namespace: message.namespace,
        element_name: message.element_name,
        language: %{
          policy: message.language_policy,
          code: message.language_code
        },
        localizable_params: format_params(message.params)
      }
    }
  end
end
