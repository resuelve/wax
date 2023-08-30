defmodule WhatsappApiRequest do
  use HTTPoison.Base
  require Logger

  @default_headers [{"Content-Type", "application/json"}]
  # Parámetros para reintentos
  @attempts_limit 3
  @back_off_in_ms 200

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

  def apply_request(_url, _method, _params, @attempts_limit), do: {:error, :max_attempts_exceeded}

  def apply_request(url, method, params, attempts) do
    apply(__MODULE__, method, params)
  rescue
    reason ->
      retry = attempts + 1

      IO.inspect(reason, label: :reason)

      Logger.info("Got a HTTP Error. Attempts: #{retry} of #{@attempts_limit}",
        reason: inspect(reason),
        attempts: retry,
        params: inspect(params),
        url: url,
        method: "#{method}"
      )

      :timer.sleep(retry * @back_off_in_ms)
      apply_request(url, method, params, retry)
  end
end
