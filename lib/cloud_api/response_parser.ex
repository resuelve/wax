defmodule Wax.CloudAPI.ResponseParser do
  @moduledoc """
  Parsing Cloud API server responses
  """

  alias HTTPoison.Response

  @doc """
  Parses the server response into a more user friendly map.

  TODO: Implement a WhatsappResponse struct
  """
  def parse(%Response{status_code: 200, body: body}, :media_upload) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, %{"id" => media_id}} ->
        {:ok, media_id}

      _ ->
        {:error, "Media ID not found in response: #{body}"}
    end
  end

  def parse(%Response{status_code: 200, body: body}, :media_data) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, %{"url" => media_url}} ->
        {:ok, media_url}

      {:ok, %{"error" => %{"message" => error_message}}} ->
        {:error, "Media not found: #{error_message}"}

      _ ->
        {:error, "Unexpected error when downloading file: #{body}"}
    end
  end

  def parse(%Response{status_code: 200, body: body}, :media_download) when is_bitstring(body) do
    {:ok, body}
  end

  def parse(%Response{status_code: 200, body: body}, _type) do
    {:ok, body}
  end

  def parse(
        %Response{
          body: %{"error" => %{"code" => error_code, "error_data" => %{"details" => error}}}
        },
        _type
      ) do
    {:error, "Cloud API Error #{error_code}: #{error}"}
  end

  def parse(
        %Response{
          body: %{"error" => %{"code" => error_code, "type" => type, "message" => message}}
        },
        _type
      ) do
    {:error, "Cloud API Error #{error_code} [#{type}]: #{message}"}
  end

  def parse(%Response{status_code: status_code, body: body}, _type) do
    {:error, "HTTP Error #{status_code}: #{inspect(body)}"}
  end

  def parse({:error, :max_attempts_exceeded}, _type) do
    {:error, "Max attempts exceeded"}
  end

  def parse(_response, _type) do
    {:error, "Error parsing response"}
  end
end
