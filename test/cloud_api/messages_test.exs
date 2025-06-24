defmodule Wax.CloudAPI.MessagesTest do
  use Whatsapp.Case

  alias Wax.CloudAPI.{Auth, Messages}
  alias Wax.Messages.Message

  setup do
    bypass = Bypass.open()
    Application.put_env(:wax, :cloud_api_url, "http://localhost:#{bypass.port}")

    test_wa_number_id = "TEST0000000001"
    test_token = "TESTTOKEN999"

    auth = Auth.new(test_wa_number_id, test_token)

    {:ok, bypass: bypass, auth: auth}
  end

  describe "Text messages" do
    test "Send a text message", %{bypass: bypass, auth: auth} do
      test_to_number = "TEST550000000001"

      Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/messages", fn conn ->
        response = ~s<{"messaging_product": "whatsapp", "messages": [{"id": "TESTMESSAGEID"}]}>
        Plug.Conn.resp(conn, 200, response)
      end)

      message =
        test_to_number
        |> Message.new()
        |> Message.set_type(:text)
        |> Message.set_text("Text message test")

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} = Messages.send(message, auth)
    end

    test "Cannot send a text message with no text", %{auth: auth} do
      test_to_number = "TEST550000000001"

      message =
        test_to_number
        |> Message.new()
        |> Message.set_type(:text)

      assert {:error, _error} = Messages.send(message, auth)
    end

    test "Cannot send a text message with an empty string", %{auth: auth} do
      test_to_number = "TEST550000000001"

      message =
        test_to_number
        |> Message.new()
        |> Message.set_type(:text)
        |> Message.set_text("")

      assert {:error, _error} = Messages.send(message, auth)
    end
  end

  describe "Various errors" do
    test "Sending a message of an unsupported type", %{auth: auth} do
      test_to_number = "TEST550000000001"

      message =
        test_to_number
        |> Message.new()
        |> Message.set_type(:contact)
        |> Message.set_text("")

      assert {:error, _error} = Messages.send(message, auth)
    end

    test "Sending a message to an empty number", %{auth: auth} do
      message =
        ""
        |> Message.new()
        |> Message.set_type(:text)
        |> Message.set_text("Some message")

      assert {:error, _error} = Messages.send(message, auth)
    end
  end
end
