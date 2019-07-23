defmodule Whatsapp.Api.Messages do
  @moduledoc """
  Módulo para el manejo de mensajes de Whatsapp
  """

  alias Whatsapp.Models.MessageOutbound
  alias Whatsapp.Models.MessageOutboundHsm
  alias WhatsappApiRequest
  alias Whatsapp.Models.Media, as: MediaModel
  alias Whatsapp.Api.Media, as: MediaApi

  require Logger

  def send(%MessageOutbound{} = message, auth_header) do
    with {:ok, message_validated} <- MessageOutbound.validate(message) do
      headers = [auth_header]

      message = MessageOutbound.to_json(message_validated)
      WhatsappApiRequest.post("messages", message, headers)
    end
  end

  def send_hsm(%MessageOutboundHsm{} = message, auth_header) do
    with {:ok, message_validated} <- MessageOutboundHsm.validate(message) do
      headers = [auth_header]

      message = MessageOutboundHsm.to_json(message_validated)
      WhatsappApiRequest.post("messages", message, headers)
    end
  end

  def send_media(message, auth_header) do
    with {:ok, media_id} <- MediaApi.upload(message, auth_header) do
      params =
        message
        |> MessageOutboundMedia.set_media_id(media_id)
        |> MessageOutboundMedia.to_json()

      WhatsappApiRequest.post("messages", params, [auth_header])
    end
  end

end
