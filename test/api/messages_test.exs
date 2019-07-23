defmodule Whatsapp.Api.MessagesTest do
  use Whatsapp.Case

  import Mock
  alias Whatsapp.Api.Messages
  alias Whatsapp.Models.MessageOutbound
  alias Whatsapp.Models.MessageOutboundHsm
  alias Whatsapp.Models.MessageOutboundMedia

  @auth_header {"Authorization", "Basic token"}

  test "Should send text message" do
    with_mocks([{
      WhatsappApiRequest,
      [],
      [
        post: fn (_, _, _) ->
          %{}
        end
      ]
    }]) do
      message = MessageOutbound.new(
        to: "5562",
        type: "text",
        body: "hola!"
      )
      assert Messages.send(message, "token") == %{}
    end
  end

  test "Should send hsm message" do
    with_mocks([{
      WhatsappApiRequest,
      [],
      [
        post: fn (_, _, _) ->
          %{}
        end
      ]
    }]) do
      message = MessageOutboundHsm.new(
        to: "5562",
        type: "text",
        body: "hola!"
      )
      assert Messages.send_hsm(message, @auth_header) == %{}
    end
  end

  test "Should send media message" do
    with_mocks([{
      WhatsappApiRequest,
      [],
      [
        post: fn (_, _, _) ->
          %{}
        end
      ]
    }]) do
      message = MessageOutboundMedia.new(
        to: "5562",
        type: "text",
        file_name: "mi_archivo.pdf",
        data: "123456"
      )
      assert Messages.send_media(message, "token") == %{}
    end
  end
end
