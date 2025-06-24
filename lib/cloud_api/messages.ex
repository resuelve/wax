defmodule Wax.CloudAPI.Messages do
  @moduledoc """
  Whatsapp Messages

  You can send different types of messages using send/2
  """

  alias Wax.CloudAPI.Auth
  alias Wax.Messages.Message
  alias Whatsapp.Parser

  @base_url "https://graph.facebook.com/v23.0/"

  @spec send(Message.t(), String.t()) :: :ok | {:error, String.t()}
  def send(%Message{} = message, %Auth{} = auth) do
    with :ok <- Message.validate(message) do
      headers = [{"Authorization", "Bearer " <> auth.token}]

      @base_url
      |> URI.merge("/#{auth.whatsapp_number_id}/messages")
      |> URI.to_string()
      |> WhatsappApiRequest.rate_limit_request(:post!, message, headers)
      |> Parser.parse(:messages_send)
    end
  end
end
