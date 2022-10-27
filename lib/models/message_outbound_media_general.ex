defmodule Whatsapp.Models.MessageOutboundMediaGeneral do
  @moduledoc """
  Estructura del mensaje de Whatsapp
  """

  require Logger

  @enforce_keys [:to]

  defstruct(
    recipient: "individual",
    to: nil,
    type: nil,
    media_id: nil,
    caption: nil
  )

  @type t :: %__MODULE__{}

  @doc """
  Crea un mensaje nuevo
  """
  @spec new(Keyword.t()) :: __MODULE__.t()
  def new(options) do
    attrs =
      options
      |> Enum.into(Map.new())

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
      type: message.type,
      "#{message.type}": _convert_to_parameter(message.type, message.media_id, message.caption)
    }
  end

  def _convert_to_parameter(type, value, caption) do
    Map.new()
    |> Map.put(type, value)
    |> Map.put("caption", caption)
    |> _convert_to_parameter()
  end

  def _convert_to_parameter(%{"audio" => media_id}) do
    %{
      id: media_id
    }
  end

  def _convert_to_parameter(%{"document" => media_id, "caption" => caption}) do
    %{
      id: media_id,
      filename: caption
    }
  end

  def _convert_to_parameter(%{"video" => media_id, "caption" => caption}) do
    %{
      id: media_id,
      caption: caption
    }
  end

  def _convert_to_parameter(%{"image" => media_id, "caption" => caption}) do
    %{
      id: media_id,
      caption: caption
    }
  end
end
