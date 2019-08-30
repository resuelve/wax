defmodule WhatsappApiRequestMedia do
  use HTTPoison.Base

  @default_headers []

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

  def rate_limit_request(url, method_get, headers) when method_get in [:get, :get!] do
    [_, _, host, _] = Regex.run(~r/(.+:\/\/)?([^\/]+)(\/.*)*/, url)
    case ExRated.check_rate(host, @scale, @limit) do
      {:ok, _} ->
        apply(__MODULE__, method_get, [url, headers])

      {:error, _} ->
        :timer.sleep(100)
        rate_limit_request(url, method_get, headers)
    end
  end

  def rate_limit_request(url, method, data, headers) do
    [_, _, host, _] = Regex.run(~r/(.+:\/\/)?([^\/]+)(\/.*)*/, url)
    case ExRated.check_rate(host, @scale, @limit) do
      {:ok, _} ->
        apply(__MODULE__, method, [url, data, headers])

      {:error, _} ->
        :timer.sleep(100)
        rate_limit_request(url, method, data, headers)
    end
  end

  def process_request_headers(headers \\ []) do
    headers ++ @default_headers
  end

  def process_response_body("{" <> _ = body) do
    Poison.decode!(body)
  end

  def process_response_body(body) do
    body
  end
end
