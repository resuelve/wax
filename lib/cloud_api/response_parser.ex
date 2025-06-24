defmodule Wax.CloudAPI.ResponseParser do
  @moduledoc """
  Parsing Cloud API server responses
  """

  alias HTTPoison.Response

  @doc """
  Parses the server response into a more user friendly map.

  TODO: Implement a WhatsappResponse struct
  """
  defp _parse(%Response{status_code: 200, body: body}, _type) do
    {:ok, body}
  end

  defp _parse(%Response{status_code: status_code, body: body}, _type) do
    {:error, "HTTP Error #{status_code}: #{inspect(body)}"}
  end

  def parse({:error, :max_attempts_exceeded}, _type) do
    {:error, "Max attempts exceeded"}
  end

  def parse(_response, _type) do
    {:error, "Error parsing response"}
  end
end
