defmodule WhatsappApiRequestMedia do
  use HTTPoison.Base

  @default_headers []

  def process_request_url(url) do
    base_url = Application.get_env(:whatsapp_api, :url_base) || ""
    base_url <> url
  end

  def process_request_options(options) do
    [
      hackney: [:insecure],
      connect_timeout: 10_000,
      recv_timeout: 10_000,
      timeout: 10_000
    ] ++ options
  end

  def process_request_headers(headers) do
    headers ++ @default_headers
  end
end
