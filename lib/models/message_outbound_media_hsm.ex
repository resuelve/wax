defmodule Whatsapp.Models.MessageOutboundMediaHsm do
  @moduledoc """
  Model in charge of sending templates with media:
  https://developers.facebook.com/docs/whatsapp/api/messages/message-templates/media-message-templates
  """

  require Logger
  alias __MODULE__

  @enforce_keys [:to, :language_policy, :params, :file_name, :data, :type]
  defstruct(
    to: nil,
    namespace: nil,
    element_name: nil,
    language_policy: nil,
    language_code: nil,
    params: [],
    type: nil,
    file_name: nil,
    caption: nil,
    mime_type: nil,
    data: nil,
    extension: nil,
    media_id: nil
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

  def set_media_id(media, media_id) do
    %{media | media_id: media_id}
  end

  defp _not_empty_parameters(%MessageOutboundMediaHsm{params: params}) when length(params) > 0,
    do: :ok

  defp _not_empty_parameters(_), do: {:error, "Empty parameters"}

  # Valida que el tipo de selección de lenguaje sea válido
  @spec _validate_policy(MessageOutboundMediaHsm.t()) :: String.t()
  defp _validate_policy(%MessageOutboundMediaHsm{language_policy: language_policy} = msg)
       when language_policy in @valid_language_policies do
    {:ok, msg}
  end

  defp _validate_policy(_message), do: {:error, "Invalid language policy"}

  def validate(message) do
    with {:ok, message} <- _validate_policy(message),
         :ok <- _not_empty_parameters(message) do
      :ok
    end
  end

  def _format_params(params) when is_list(params) do
    Enum.map(params, &_convert_to_parameter/1)
  end

  def _convert_to_parameter(type, value) do
    Map.new()
    |> Map.put(type, value)
    |> _convert_to_parameter()
  end

  def _convert_to_parameter(text) when is_binary(text) do
    %{type: "text", text: text}
  end

  def _convert_to_parameter(%{"text" => replacement_text}) do
    %{type: "text", text: replacement_text}
  end

  def _convert_to_parameter(%{"document" => media_id}) do
    %{
      type: "document",
      document: %{
        id: media_id
      }
    }
  end

  def _convert_to_parameter(%{"video" => media_id}) do
    %{
      type: "video",
      video: %{
        id: media_id
      }
    }
  end

  def _convert_to_parameter(%{"image" => media_id}) do
    %{
      type: "image",
      image: %{
        id: media_id
      }
    }
  end

  def to_json(%__MODULE__{} = message) do
    %{
      to: message.to,
      type: "template",
      template: %{
        namespace: message.namespace,
        name: message.element_name,
        language: %{
          policy: message.language_policy,
          code: message.language_code
        },
        components: [
          %{
            type: "header",
            parameters: [_convert_to_parameter(message.type, message.media_id)]
          },
          %{
            type: "body",
            parameters: _format_params(message.params)
          }
        ]
      }
    }
  end
end
