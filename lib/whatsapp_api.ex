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

  def get_auth_header(provider) do
    token = AuthServer.get_token(provider)
    {"Authorization", "Bearer #{token}"}
  end

  @doc """
  Sends a text message
  """
  @spec send_message(MessageOutbound.t(), String.t()) :: map()
  def send_message(%MessageOutbound{} = message, provider) do
    auth_header = get_auth_header(provider)
    Messages.send(message, auth_header)
  end

  @spec send_hsm(MessageOutboundHsm.t(), String.t()) :: map()
  def send_hsm(%MessageOutboundHsm{} = message, provider) do
    auth_header = get_auth_header(provider)
    Messages.send_hsm(message, auth_header)
  end

  @spec send_media(MessageOutboundMedia.t(), String.t()) :: map()
  def send_media(%MessageOutboundMedia{} = message, provider) do
    auth_header = get_auth_header(provider)
    Messages.send_media(message, auth_header)
  end

  @doc """
  Check if phone number is valid an gets wa_id
  """
  @spec check(String.t(), String.t()) :: map()
  def check(phone, provider) do
    auth_header = get_auth_header(provider)
    Contacts.check(phone, auth_header)
  end
end
