defmodule Whatsapp.Api.Messages do
  @moduledoc """
  Whatsapp api messages
  """

  @parser Application.get_env(:whatsapp_api, :parser)

  alias Whatsapp.Models.MessageOutbound
  alias Whatsapp.Models.MessageOutboundHsm
  alias Whatsapp.Models.MessageOutboundMedia
  alias WhatsappApiRequest
  alias Whatsapp.Models.Media, as: MediaModel
  alias Whatsapp.Api.Media, as: MediaApi

  require Logger

  def send(%MessageOutbound{} = message, auth_header) do
    with {:ok, message_validated} <- MessageOutbound.validate(message) do
      message = MessageOutbound.to_json(message_validated)

      "/messages"
      |> WhatsappApiRequest.post!(message, [auth_header])
      |> @parser.parse(:messages_send)
    end
  end

  def send_hsm(%MessageOutboundHsm{} = message, auth_header) do
    with {:ok, message_validated} <- MessageOutboundHsm.validate(message) do
      headers = [auth_header]

      message = MessageOutboundHsm.to_json(message_validated)

      "/messages"
      |> WhatsappApiRequest.post!(message, headers)
      |> @parser.parse(:messages_send)
    end
  end

  def send_media(message, auth_header) do
    with {:ok, media_id} <- MediaApi.upload(message, auth_header) do
      params =
        message
        |> MessageOutboundMedia.set_media_id(media_id)
        |> MessageOutboundMedia.to_json()

      "/messages"
      |> WhatsappApiRequest.post!(params, [auth_header])
      |> @parser.parse(:messages_send)
    end
  end
end
