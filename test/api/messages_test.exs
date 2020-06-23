defmodule Whatsapp.Api.MessagesTest do
  use Whatsapp.Case

  import Mock
  alias Whatsapp.Api.Messages

  alias Whatsapp.Models.{
    MessageOutbound,
    MessageOutboundHsm,
    MessageOutboundMedia,
    MessageOutboundMediaHsm
  }

  @response %{
    "messages" => [
      %{
        "id" => "message-id"
      }
    ]
  }

  @http_success_response %HTTPoison.Response{
    body: @response
  }

  test "Should send text message", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, _, _, _ -> @http_success_response end
        ]
      }
    ]) do
      message =
        MessageOutbound.new(
          to: "15162837151",
          type: "text",
          body: "hola!"
        )

      assert Messages.send(token_info, message) == @response
    end
  end

  test "Should send hsm message", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, _, _, _ -> @http_success_response end
        ]
      }
    ]) do
      message =
        MessageOutboundHsm.new(
          to: "15162837151",
          namespace: "resuelve:fintech",
          element_name: "welcome",
          language_code: "es",
          params: []
        )

      assert Messages.send_hsm(token_info, message) == @response
    end
  end

  test "Should send media message", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, _, _, _ -> @http_success_response end
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
          file_name: "mi_archivo.pdf",
          data: "data:text/plain;base64,SGVsbG8gd29ybGQh",
          type: "document"
        )

      assert Messages.send_media(token_info, message) == @response
    end
  end

  test "Sending HSM with media message", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, _, _, _ -> @http_success_response end
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
        MessageOutboundMediaHsm.new(
          to: "15162837151",
          namespace: "resuelve:fintech",
          element_name: "welcome",
          language_code: "es",
          file_name: "mi_archivo.pdf",
          data: "data:text/plain;base64,SGVsbG8gd29ybGQh",
          type: "document",
          params: [%{"text" => "replacement_text"}]
        )

      assert Messages.send_media_hsm(token_info, message) == @response
    end
  end

  test "Gives an error when using it with empty parameters", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, _, _, _ -> @http_success_response end
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
        MessageOutboundMediaHsm.new(
          to: "15162837151",
          namespace: "resuelve:fintech",
          element_name: "welcome",
          language_code: "es",
          file_name: "mi_archivo.pdf",
          data: "data:text/plain;base64,SGVsbG8gd29ybGQh",
          type: "document",
          params: []
        )

      assert Messages.send_media_hsm(token_info, message) == {:error, "Empty parameters"}
    end
  end
end
