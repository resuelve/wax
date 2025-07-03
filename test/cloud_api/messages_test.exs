defmodule Wax.CloudAPI.MessagesTest do
  use Whatsapp.Case

  alias Wax.CloudAPI.{Auth, Media, Messages}
  alias Wax.Messages.Message

  setup do
    bypass = Bypass.open()
    Application.put_env(:wax, :cloud_api, url: "http://localhost:#{bypass.port}", version: "")

    test_to_number = "TEST550000000001"
    test_wa_number_id = "TEST0000000001"
    test_token = "TESTTOKEN999"

    auth = Auth.new(test_wa_number_id, test_token)

    {:ok, bypass: bypass, auth: auth, to: test_to_number}
  end

  describe "Text messages" do
    test "Send a text message", %{bypass: bypass, auth: auth, to: to} do
      Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/messages", fn conn ->
        response = ~s<{"messaging_product": "whatsapp", "messages": [{"id": "TESTMESSAGEID"}]}>
        Plug.Conn.resp(conn, 200, response)
      end)

      message =
        to
        |> Message.new()
        |> Message.set_type(:text)
        |> Message.set_text("Text message test")

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} = Messages.send(message, auth)
    end

    test "Cannot send a text message with no text", %{auth: auth, to: to} do
      message =
        to
        |> Message.new()
        |> Message.set_type(:text)

      assert {:error, _error} = Messages.send(message, auth)
    end

    test "Cannot send a text message with an empty string", %{auth: auth, to: to} do
      message =
        to
        |> Message.new()
        |> Message.set_type(:text)
        |> Message.set_text("")

      assert {:error, _error} = Messages.send(message, auth)
    end
  end

  describe "Image messages" do
    test "Send an image message", %{bypass: bypass, auth: auth, to: to} do
      Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/media", fn conn ->
        response = ~s<{"id": "TEST00000000"}>
        Plug.Conn.resp(conn, 200, response)
      end)

      {:ok, media_id} =
        [extname: "png"]
        |> Briefly.create!()
        |> Media.upload(auth)

      Bypass.expect(bypass, "POST", "/#{auth.whatsapp_number_id}/messages", fn conn ->
        response = ~s<{"messaging_product": "whatsapp", "messages": [{"id": "TESTMESSAGEID"}]}>
        Plug.Conn.resp(conn, 200, response)
      end)

      message =
        to
        |> Message.new()
        |> Message.set_type(:image)

      message_with_caption = Message.add_image(message, media_id, "Test caption")

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} =
               Messages.send(message_with_caption, auth)

      message_no_caption = Message.add_image(message, media_id)

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} =
               Messages.send(message_no_caption, auth)
    end
  end

  describe "Video messages" do
    test "Send an video message", %{bypass: bypass, auth: auth, to: to} do
      Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/media", fn conn ->
        response = ~s<{"id": "TEST00000000"}>
        Plug.Conn.resp(conn, 200, response)
      end)

      {:ok, media_id} =
        [extname: "mp4"]
        |> Briefly.create!()
        |> Media.upload(auth)

      Bypass.expect(bypass, "POST", "/#{auth.whatsapp_number_id}/messages", fn conn ->
        response = ~s<{"messaging_product": "whatsapp", "messages": [{"id": "TESTMESSAGEID"}]}>
        Plug.Conn.resp(conn, 200, response)
      end)

      message =
        to
        |> Message.new()
        |> Message.set_type(:video)

      message_with_caption = Message.add_video(message, media_id, "Test caption")

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} =
               Messages.send(message_with_caption, auth)

      message_no_caption = Message.add_video(message, media_id)

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} =
               Messages.send(message_no_caption, auth)
    end
  end

  describe "Various errors" do
    test "Sending a message of an unsupported type", %{auth: auth, to: to} do
      message =
        to
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
