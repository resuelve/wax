defmodule Wax.CloudAPI do
  @moduledoc """
  Whatsapp Cloud API
  """

  @doc """
  Builds a URL for a Cloud API number and endpoint
  """
  @spec build_url(String.t(), String.t()) :: String.t()
  def build_url(whatsapp_number_id, endpoint) do
    whatsapp_number_id
    |> Path.join(endpoint)
    |> do_build_url()
  end

  def build_url(endpoint) do
    do_build_url(endpoint)
  end

  defp do_build_url(endpoint) do
    config = Application.get_env(:wax, :cloud_api)
    url = config[:url]
    api_version = config[:api_version]

    url
    |> URI.merge("#{api_version}/#{endpoint}")
    |> URI.to_string()
  end
end
