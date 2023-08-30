defmodule Whatsapp.Parser do
  alias HTTPoison.Response

  @doc """
  Intercambia el primer parametro con el segundo y llama a una función privada
  """
  def parse(response, type) do
    _parse(type, response)
  end

  defp _parse(:media_upload, %Response{body: body}) do
    %{"media" => [%{"id" => media_id}]} = body
    {:ok, media_id}
  end

  defp _parse(:media_delete, %Response{status_code: 200, body: body}) do
    {:ok, body}
  end

  defp _parse(_type, %Response{body: body}) do
    body
  end

  defp _parse(_type, {:error, :max_attempts_exceeded}), do:
    {:error, "Max attempts exceeded"}

  defp _parse(_type, _response) do
    {:error, "Error parsing response"}
  end
end
