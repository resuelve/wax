defmodule WhatsappApiBaseRequest do
  @moduledoc """
  Base module to handle requests and retries
  """
  require Logger

  @attempts_limit 4

  # 20 requests per second
  @limit 20
  @scale 1_000

  @doc """
  Check rates and make the request.
  If something goes wrong, it will retry up to 3 times.
  When the max attempts is exceeded it will return a {:error, :max_attempts_exceeded}
  """
  @spec check_rate_and_prepare_request(module(), String.t(), atom(), list(), non_neg_integer()) ::
          HTTPoison.Response.t() | {:error, :max_attempts_exceeded}
  def check_rate_and_prepare_request(_module, _url, _method, _params, @attempts_limit),
    do: {:error, :max_attempts_exceeded}

  def check_rate_and_prepare_request(module, url, method, params, attempts) do
    [_, _, host, _] = Regex.run(~r/(.+:\/\/)?([^\/]+)(\/.*)*/, url)

    case ExRated.check_rate(host, @scale, @limit) do
      {:ok, _} ->
        apply_request(module, url, method, params, attempts)

      {:error, _} ->
        :timer.sleep(100)
        check_rate_and_prepare_request(module, url, method, params, attempts)
    end
  end

  defp apply_request(module, url, method, params, attempts) do
    apply(module, method, params)
  rescue
    reason ->
      Logger.info("Got a HTTP Error, attempts #{attempts}",
        reason: inspect(reason),
        params: inspect(params),
        url: url,
        method: "#{method}"
      )

      check_rate_and_prepare_request(module, url, method, params, attempts + 1)
  end
end
