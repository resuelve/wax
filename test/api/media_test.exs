defmodule Whatsapp.Api.MediaTest do
  use Whatsapp.Case

  import Mock
  alias Whatsapp.Api.Media

  test "Should download file", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequestMedia,
        [],
        [
          rate_limit_request: fn _, _, _ ->
            %HTTPoison.Response{
              body: "binary-data"
            }
          end
        ]
      }
    ]) do
      media_id = 1
      assert Media.download(token_info, media_id) == "binary-data"
    end
  end

  test "Deletes a media file", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequestMedia,
        [],
        [
          rate_limit_request: fn _, _, _ ->
            %HTTPoison.Response{
              status_code: 200,
              body: "{}"
            }
          end
        ]
      }
    ]) do
      media_id = 1
      assert Media.delete(token_info, media_id) == {:ok, "{}"}
    end
  end
end
