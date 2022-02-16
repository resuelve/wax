defmodule Whatsapp.Models.MessageOutboundTemplate do
  @moduledoc """
  Estructura del mensaje de Whatsapp Tempalte
  """

  require Logger
  alias __MODULE__

  @enforce_keys [:to, :language_policy]

  defstruct(
    to: nil,
    namespace: nil,
    name: nil,
    language_policy: nil,
    language_code: nil
  )

  @valid_language_policies ["deterministic"]

  @default_values %{
    language_policy: "deterministic"
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
  @spec _validate_policy(MessageOutboundTemplate.t()) :: String.t()
  defp _validate_policy(%MessageOutboundTemplate{language_policy: language_policy} = msg)
       when language_policy in @valid_language_policies do
    {:ok, msg}
  end

  defp _validate_policy(_message), do: {:error, "Invalid language policy"}

  def validate(message) do
    with {:ok, message} <- _validate_policy(message) do
      {:ok, message}
    end
  end

  def to_json(%__MODULE__{} = message) do
    %{
      to: message.to,
      type: "template",
      template: message.template
    }
  end
end