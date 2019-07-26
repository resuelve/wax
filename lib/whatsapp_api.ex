defmodule WhatsappApi do
  @moduledoc """
  Documentation for WhatsappApi.
  """

  alias Whatsapp.Api.Messages
  alias Whatsapp.Models.MessageOutbound
  alias Whatsapp.Models.MessageOutboundHsm
  alias Whatsapp.Models.MessageOutboundMedia
  alias Whatsapp.Api.Contacts
  alias Whatsapp.Auth.Server, as: AuthServer

  @doc """
  Sends a text message
  """
  @spec send_message(MessageOutbound.t(), String.t()) :: map()
  def send_message(%MessageOutbound{} = message, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Messages.send(message)
  end

  @spec send_hsm(MessageOutboundHsm.t(), String.t()) :: map()
  def send_hsm(%MessageOutboundHsm{} = message, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Messages.send_hsm(message)
  end

  @spec send_media(MessageOutboundMedia.t(), String.t()) :: map()
  def send_media(%MessageOutboundMedia{} = message, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Messages.send_media(message)
  end

  @doc """
  Check if phone number is valid an gets wa_id
  """
  @spec check(String.t(), String.t()) :: map()
  def check(phone, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Contacts.check(phone)
  end
end
