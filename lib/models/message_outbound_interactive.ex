defmodule Whatsapp.Models.MessageOutboundInteractive do
  @moduledoc """
  Estructura del mensaje de Whatsapp
  """

  require Logger

  @enforce_keys [:to]

  defstruct(
    recipient: "individual",
    to: nil,
    type: "interactive",
    interactive: nil
  )

  @type t :: %__MODULE__{}

  @doc """
  Crea un mensaje nuevo
  """
  @spec new(Keyword.t()) :: __MODULE__.t()
  def new(options) do
    attrs = Enum.into(options, Map.new())
    Kernel.struct(__MODULE__, attrs)
  end

  def validate(message) do
    {:ok, message}
  end

  @doc """
  Genera la estructura necesaria para enviar un mensaje a Whatsapp
  """
  @spec to_json(__MODULE__.t()) :: map
  def to_json(%__MODULE__{} = message) do
    %{
      recipient_type: message.recipient,
      to: message.to,
      type: "interactive",
      interactive: message.interactive
    }
  end
end
