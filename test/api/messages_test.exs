defmodule Whatsapp.Api.MessagesTest do
  use Whatsapp.Case

  import Mock
  alias Whatsapp.Api.Messages
  alias Whatsapp.Models.MessageOutbound
  alias Whatsapp.Models.MessageOutboundHsm
  alias Whatsapp.Models.MessageOutboundMedia

  @auth_header {"Authorization", "Bearer token"}

  test "Should send text message" do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          post!: fn _, _, _ ->
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

      assert Messages.send(message, @auth_header) == %{}
    end
  end

  test "Should send hsm message" do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          post!: fn _, _, _ ->
            %HTTPoison.Response{body: %{}}
          end
        ]
      }
    ]) do
      message =
        MessageOutboundHsm.new(
          to: "15162837151",
          type: "text",
          body: "hola!"
        )

      assert Messages.send_hsm(message, @auth_header) == %{}
    end
  end

  test "Should send media message" do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          post!: fn "/messages", _, _ ->
            %HTTPoison.Response{body: %{}}
          end
        ]
      },
      {
        WhatsappApiRequestMedia,
        [],
        [
          post!: fn "/media", _, _ ->
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

      assert Messages.send_media(message, @auth_header) == %{}
    end
  end
end
