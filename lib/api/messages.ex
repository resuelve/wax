defmodule Whatsapp.Api.Messages do
  @moduledoc """
  Whatsapp api messages
  """

  @parser Application.get_env(:wax, :parser)

  alias Whatsapp.Models.{
    MessageOutbound,
    MessageOutboundHsm,
    MessageOutboundMedia,
    MessageOutboundMediaHsm
  }

  alias WhatsappApiRequest
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

  def send_media_hsm({url, auth_header} = token_info, %MessageOutboundMediaHsm{} = message) do
    with {:ok, message_validated} <- MessageOutboundMediaHsm.validate(message),
         {:ok, media_id} <- MediaApi.upload(token_info, message) do
      params =
        message
        |> MessageOutboundMediaHsm.set_media_id(media_id)
        |> MessageOutboundMediaHsm.to_json()

      url
      |> Kernel.<>("/messages")
      |> WhatsappApiRequest.rate_limit_request(:post!, params, [auth_header])
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
