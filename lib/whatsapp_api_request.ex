defmodule WhatsappApiRequest do
  use HTTPoison.Base

  @default_headers [{"Content-Type", "application/json"}]

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

  def process_request_body(body) do
    Poison.encode!(body)
  end

  def process_request_headers(headers) do
    headers ++ @default_headers
  end

  def process_response_body(body) do
    Poison.decode!(body)
  end
end
