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

  def send({url, auth_header}, %MessageOutbound{} = message) do
    with {:ok, message_validated} <- MessageOutbound.validate(message) do
      message = MessageOutbound.to_json(message_validated)

      url
      |> Kernel.<>("/messages")
      |> WhatsappApiRequest.rate_limit_request(:post!, message, [auth_header])
      |> @parser.parse(:messages_send)
    end
  end

  def send_hsm({url, auth_header}, %MessageOutboundHsm{} = message) do
    with {:ok, message_validated} <- MessageOutboundHsm.validate(message) do
      headers = [auth_header]

      message = MessageOutboundHsm.to_json(message_validated)

      url
      |> Kernel.<>("/messages")
      |> WhatsappApiRequest.rate_limit_request(:post!, message, headers)
      |> @parser.parse(:messages_send)
    end
  end

  def send_media({url, auth_header} = token_info, message) do
    with {:ok, media_id} <- MediaApi.upload(token_info, message) do
      params =
        message
        |> MessageOutboundMedia.set_media_id(media_id)
        |> MessageOutboundMedia.to_json()

      url
      |> Kernel.<>("/messages")
      |> WhatsappApiRequest.rate_limit_request(:post!, params, [auth_header])
      |> @parser.parse(:messages_send)
    end
  end
end
