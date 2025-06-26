defmodule Wax.CloudAPI do
  @moduledoc """
  Whatsapp Cloud API
  """

  @doc """
  Builds a URL for a Cloud API number and endpoint
  """
  @spec build_url(String.t(), String.t()) :: String.t()
  def build_url(whatsapp_number_id, endpoint) do
    config = Application.get_env(:wax, :cloud_api)
    url = config[:url]
    api_version = config[:api_version]

    url
    |> URI.merge("#{api_version}/#{whatsapp_number_id}/#{endpoint}")
    |> URI.to_string()
  end
end
