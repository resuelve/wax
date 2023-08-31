defmodule WhatsappApiRequest do
  use HTTPoison.Base
  require Logger

  @default_headers [{"Content-Type", "application/json"}]
  # Retry params
  @attempts_limit 4
  @back_off_in_ms 100

  # 20 requests per second
  @limit 20
  @scale 1_000

  def process_request_options(options) do
    [
      hackney: [:insecure],
      connect_timeout: Application.get_env(:wax, :connect_timeout) || 10_000,
      recv_timeout: Application.get_env(:wax, :recv_timeout) || 10_000,
      timeout: Application.get_env(:wax, :timeout) || 10_000
    ] ++ options
  end

  def rate_limit_request(url, method_get, headers) when method_get in [:get, :get!] do
    [_, _, host, _] = Regex.run(~r/(.+:\/\/)?([^\/]+)(\/.*)*/, url)

    case ExRated.check_rate(host, @scale, @limit) do
      {:ok, _} ->
        apply_request(url, method_get, [url, headers], 0)

      {:error, _} ->
        :timer.sleep(100)
        rate_limit_request(url, method_get, headers)
    end
  end

  def rate_limit_request(url, method, data, headers) do
    [_, _, host, _] = Regex.run(~r/(.+:\/\/)?([^\/]+)(\/.*)*/, url)

    case ExRated.check_rate(host, @scale, @limit) do
      {:ok, _} ->
        apply_request(url, method, [url, data, headers], 0)

      {:error, _} ->
        :timer.sleep(100)
        rate_limit_request(url, method, data, headers)
    end
  end

  def process_request_body(body) do
    Jason.encode!(body)
  end

  def process_request_headers(headers \\ []) do
    headers ++ @default_headers
  end

  def process_response_body(body) do
    Jason.decode!(body)
  end

  def apply_request(url, method, params, @attempts_limit) do
    Logger.info("Failed HTTP request after 3 attempts",
      params: inspect(params),
      url: url,
      method: "#{method}"
    )

    {:error, :max_attempts_exceeded}
  end

  def apply_request(url, method, params, attempts) do
    apply(__MODULE__, method, params)
  rescue
    reason ->
      retry = attempts + 1
      retry_back_of = retry * @back_off_in_ms

      Logger.info("Got a HTTP Error, will retry in #{retry_back_of}ms",
        reason: inspect(reason),
        params: inspect(params),
        url: url,
        method: "#{method}"
      )

      :timer.sleep(retry_back_of)
      apply_request(url, method, params, retry)
  end
end
