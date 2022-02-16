defmodule WhatsappApi do
  @moduledoc """
  Documentation for WhatsappApi.
  """

  alias Whatsapp.Api.Messages

  alias Whatsapp.Models.{
    MessageOutbound,
    MessageOutboundHsm,
    MessageOutboundMedia,
    MessageOutboundMediaHsm,
    MessageOutboundInteractive,
    MessageOutboundMediaIdHsm,
    MessageOutboundTemplate
  }

  alias Whatsapp.Api.Contacts
  alias Whatsapp.Api.Media
  alias Whatsapp.Api.Settings
  alias Whatsapp.Api.Health
  alias Whatsapp.Api.Users
  alias Whatsapp.Api.Account
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

  @spec send_media_hsm(MessageOutboundMediaHsm.t(), String.t()) :: map()
  def send_media_hsm(%MessageOutboundMediaHsm{} = message, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Messages.send_media_hsm(message)
  end

  @spec send_media_hsm(MessageOutboundMediaIdHsm.t(), String.t()) :: map()
  def send_media_hsm(%MessageOutboundMediaIdHsm{} = message, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Messages.send_media_hsm(message)
  end

  @spec send_message_interactive(MessageOutboundInteractive.t(), String.t()) :: map()
  def send_message_interactive(%MessageOutboundInteractive{} = message, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Messages.send_message_interactive(message)
  end

  @spec send_template(MessageOutboundTemplate.t(), String.t()) :: map()
  def send_template(%MessageOutboundTemplate{} = message, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Messages.send_template(message)
  end

  @spec delete_media(String.t(), String.t()) :: tuple()
  def delete_media(media_id, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Media.delete(media_id)
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

  @doc """
  Check if phone list numbers are valid an gets wa_id
  """
  @spec check_list([String.t()], String.t()) :: map()
  def check_list(phone_list, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Contacts.check_list(phone_list)
  end

  def download(media_id, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Media.download(media_id)
  end

  @doc """
  Obtener la configuración de la cuenta
  """
  @spec get_application(String.t()) :: map()
  def get_application(provider) do
    provider
    |> AuthServer.get_token_info()
    |> Settings.get_application()
  end

  @doc """
  Actualiza la configuración de la cuenta
  """
  @spec update_application(map(), String.t()) :: map()
  def update_application(data, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Settings.update_application(data)
  end

  def two_step(pin, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Settings.two_step(pin)
  end

  @doc """
  Check whatsapp health
  """
  @spec get_health(String.t()) :: map()
  def get_health(provider) do
    provider
    |> AuthServer.get_token_info()
    |> Health.get_summary()
  end

  def logout(provider) do
    provider
    |> AuthServer.get_token_info()
    |> Users.logout()
  end

  def create_user(provider, data) do
    provider
    |> AuthServer.get_token_info()
    |> Users.create(data)
  end

  def create_account(data, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Account.create(data)
  end

  def verify_account(code, provider) do
    provider
    |> AuthServer.get_token_info()
    |> Account.verify(code)
  end
end
