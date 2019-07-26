defmodule WhatsappApiRequest do
  use HTTPoison.Base

  @default_headers [{"Content-Type", "application/json"}]

  # 20 requests per second
  @limit 20
  @scale 1_000

  def process_request_options(options) do
    [
      hackney: [:insecure],
      connect_timeout: 10_000,
      recv_timeout: 10_000,
      timeout: 10_000
    ] ++ options
  end

  def rate_limit_request(url, method, data, headers) do
    [_, host, _] = Regex.run(~r/(.+:\/\/)?([^\/]+)(\/.*)*/, url)
    case ExRated.check_rate(host, @scale, @limit) do
      {:ok, _} ->
        apply(__MODULE__, method, [data, url, headers])

      {:error, _} ->
        :timer.sleep(100)
        rate_limit_request(url, data, method, headers)
    end
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
