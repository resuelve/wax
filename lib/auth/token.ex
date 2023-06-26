defmodule Whatsapp.Auth.Token do
  alias Whatsapp.Auth.Manager

  @spec renew(%Whatsapp.Models.WhatsappProvider{}, map()) :: map()
  def renew(provider, providers_tokens_data) do
    try do
      case Manager.login(provider) do
        {:ok, new_token_data} ->
          Map.put(providers_tokens_data, provider.name, new_token_data)

        {:error, reason} ->
          Map.put(providers_tokens_data, :errors, reason)
      end
    rescue
      error ->
        previous_errors = Map.get(providers_tokens_data, :errors, [])
        errors = [{provider.name, inspect(error)} | previous_errors]
        Map.put(providers_tokens_data, :errors, errors)
    end
  end
end
