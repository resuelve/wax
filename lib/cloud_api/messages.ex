defmodule Wax.CloudAPI.Messages do
  @moduledoc """
  Whatsapp Messages

  You can send different types of messages using send/2
  """

  alias Wax.CloudAPI.{Auth, ResponseParser}
  alias Wax.Messages.Message

  @spec send(Message.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def send(%Message{} = message, %Auth{} = auth) do
    with :ok <- Message.validate(message) do
      headers = [{"Authorization", "Bearer " <> auth.token}]

      :wax
      |> Application.get_env(:cloud_api_url)
      |> URI.merge("/#{auth.whatsapp_number_id}/messages")
      |> URI.to_string()
      |> WhatsappApiRequest.rate_limit_request(:post!, message, headers)
      |> ResponseParser.parse(:messages_send)
    end
  end
end
