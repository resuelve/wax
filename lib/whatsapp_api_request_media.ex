defmodule WhatsappApiRequestMedia do
  use HTTPoison.Base

  @default_headers []

  def process_request_options(options) do
    [
      hackney: [:insecure],
      connect_timeout: Application.get_env(:wax, :connect_timeout) || 10_000,
      recv_timeout: Application.get_env(:wax, :recv_timeout) || 10_000,
      timeout: Application.get_env(:wax, :timeout) || 10_000
    ] ++ options
  end

  def rate_limit_request(url, method_get, headers) when method_get in [:get, :get!],
    do: WhatsappApiBaseRequest.check_rate_and_prepare_request(__MODULE__, url, method_get, [url, headers], 0)

  def rate_limit_request(url, method, data, headers),
    do: WhatsappApiBaseRequest.check_rate_and_prepare_request(__MODULE__, url, method, [url, data, headers], 0)

  def process_request_headers(headers \\ []), do: headers ++ @default_headers

  def process_response_body("{" <> _ = body), do: Jason.decode!(body)

  def process_response_body(body), do: body
end
