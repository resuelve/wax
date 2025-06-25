defmodule WhatsappApiRequest do
  use HTTPoison.Base

  @default_headers [{"Content-Type", "application/json"}]

  def process_request_options(options) do
    [
      hackney: [:insecure],
      connect_timeout: Application.get_env(:wax, :connect_timeout) || 10_000,
      recv_timeout: Application.get_env(:wax, :recv_timeout) || 10_000,
      timeout: Application.get_env(:wax, :timeout) || 10_000
    ] ++ options
  end

  @spec rate_limit_request(url(), method(), body(), headers()) ::
          HTTPoison.Response.t() | {:error, :max_attempts_exceeded}
  def rate_limit_request(url, method_get, headers) when method_get in [:get, :get!],
    do:
      WhatsappApiBaseRequest.check_rate_and_prepare_request(
        __MODULE__,
        url,
        method_get,
        [url, headers],
        0
      )

  def rate_limit_request(url, method, body, headers),
    do:
      WhatsappApiBaseRequest.check_rate_and_prepare_request(
        __MODULE__,
        url,
        method,
        [url, body, headers],
        0
      )

  def process_request_body(body), do: Jason.encode_to_iodata!(body)

  def process_request_headers(headers \\ []), do: headers ++ @default_headers

  def process_response_body(body), do: Jason.decode!(body)
end
