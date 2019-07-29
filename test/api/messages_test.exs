defmodule Whatsapp.Api.MessagesTest do
  use Whatsapp.Case

  import Mock
  alias Whatsapp.Api.Messages
  alias Whatsapp.Models.MessageOutbound
  alias Whatsapp.Models.MessageOutboundHsm
  alias Whatsapp.Models.MessageOutboundMedia

  test "Should send text message", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, _, _, _ ->
            %HTTPoison.Response{body: %{}}
          end
        ]
      }
    ]) do
      message =
        MessageOutbound.new(
          to: "15162837151",
          type: "text",
          body: "hola!"
        )

      assert Messages.send(token_info, message) == %{}
    end
  end

  test "Should send hsm message", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, _, _, _ ->
            %HTTPoison.Response{body: %{}}
          end
        ]
      }
    ]) do
      message =
        MessageOutboundHsm.new(
          to: "15162837151",
        )

      assert Messages.send_hsm(token_info, message) == %{}
    end
  end

  test "Should send media message", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, :post!, _, _ ->
            %HTTPoison.Response{body: %{}}
          end
        ]
      },
      {
        WhatsappApiRequestMedia,
        [],
        [
          rate_limit_request: fn _, :post!, _, _ ->
            %HTTPoison.Response{body: %{"media" => [%{"id" => 1}]}}
          end
        ]
      }
    ]) do
      message =
        MessageOutboundMedia.new(
          to: "15162837151",
          type: "text",
          file_name: "mi_archivo.pdf",
          data: "data:text/plain;base64,SGVsbG8gd29ybGQh"
        )

      assert Messages.send_media(token_info, message) == %{}
    end
  end
end
