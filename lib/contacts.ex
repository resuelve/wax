defmodule Whatsapp.Api.Contacts do
  @moduledoc """
  Modulo para el manejo del API de Contactos
  """

  alias WhatsappApiRequest
  alias Whatsapp.Models.WhatsappProvider

  @doc """
  Valida un teléfono con el provider de Whatsapp
  """
  @spec check(WhatsappProvider.t() | String.t(), String.t(), boolean) :: boolean
  def check(provider, phone, wait \\ true) do
    with response when is_map(response) <- check_list(provider, [phone], wait) do
      Map.get(response, phone) || false
    end
  end

  @doc """
  Valida la lista de teléfonos dada con el provider de Whatsapp
  """
  @spec check_list(WhatsappProvider.t() | String.t(), [String.t()], boolean) :: map
  def check_list(provider, phone_list, wait \\ true)

  def check_list(%WhatsappProvider{} = provider, phone_list, wait) do
    _check_list(provider, phone_list, wait)
  end

  def check_list(provider_name, phone_list, wait) do
    with %WhatsappProvider{} = provider <-
           WhatsappProviderManager.get(name: provider_name) do
      _check_list(provider, phone_list, wait)
    end
  end

  defp _check_list(provider, phone_list, wait) do
    blocking = (wait && "wait") || "no_wait"

    data = %{
      blocking: blocking,
      contacts: Enum.map(phone_list, &fix_phone_format/1)
    }

    with {:ok, %{"contacts" => contacts_response}} <-
           Request.post(data, "contacts", provider) do
      parse_contacts_response(contacts_response)
    end
  end

  @doc """
  Agrega el + a los teléfonos que no contienen uno
  """
  @spec fix_phone_format(String.t()) :: String.t()
  def fix_phone_format("+" <> _ = phone), do: phone
  def fix_phone_format(phone), do: "+" <> phone

  @doc """
  Parsea la respuesta del check de contactos de Whatsapp
  """
  @spec parse_contacts_response(list) :: list
  def parse_contacts_response(contacts_response) do
    Enum.reduce(contacts_response, %{}, fn contact, acc ->
      phone = Map.get(contact, "wa_id") || Map.get(contact, "input")
      valid? = Map.get(contact, "status") == "valid"

      Map.put(acc, phone, valid?)
    end)
  end
end
