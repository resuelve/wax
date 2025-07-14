defmodule Wax.CloudAPI.MessagesTest do
  use Whatsapp.Case

  alias Wax.CloudAPI.{Auth, Media, Messages}
  alias Wax.Messages.Media, as: MediaManager
  alias Wax.Messages.{Message, Template}

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
        [extname: ".png"]
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
        [extname: ".mp4"]
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

  describe "Audio messages" do
    test "Send an audio message", %{bypass: bypass, auth: auth, to: to} do
      Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/media", fn conn ->
        response = ~s<{"id": "TEST00000000"}>
        Plug.Conn.resp(conn, 200, response)
      end)

      {:ok, media_id} =
        [extname: ".mp3"]
        |> Briefly.create!()
        |> Media.upload(auth)

      Bypass.expect(bypass, "POST", "/#{auth.whatsapp_number_id}/messages", fn conn ->
        response = ~s<{"messaging_product": "whatsapp", "messages": [{"id": "TESTMESSAGEID"}]}>
        Plug.Conn.resp(conn, 200, response)
      end)

      message =
        to
        |> Message.new()
        |> Message.set_type(:audio)
        |> Message.add_audio(media_id)

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} = Messages.send(message, auth)
    end
  end

  describe "Document messages" do
    test "Send an document message", %{bypass: bypass, auth: auth, to: to} do
      Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/media", fn conn ->
        response = ~s<{"id": "TEST00000000"}>
        Plug.Conn.resp(conn, 200, response)
      end)

      {:ok, media_id} =
        [extname: ".pdf"]
        |> Briefly.create!()
        |> Media.upload(auth)

      Bypass.expect(bypass, "POST", "/#{auth.whatsapp_number_id}/messages", fn conn ->
        response = ~s<{"messaging_product": "whatsapp", "messages": [{"id": "TESTMESSAGEID"}]}>
        Plug.Conn.resp(conn, 200, response)
      end)

      message =
        to
        |> Message.new()
        |> Message.set_type(:document)

      filename = "test.pdf"

      message_with_caption = Message.add_document(message, media_id, filename, "Test caption")

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} =
               Messages.send(message_with_caption, auth)

      message_no_caption = Message.add_document(message, media_id, filename)

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} =
               Messages.send(message_no_caption, auth)
    end
  end

  describe "Template messages" do
    test "Sends a template message", %{bypass: bypass, auth: auth, to: to} do
      Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/media", fn conn ->
        response = ~s<{"id": "TEST00000000"}>
        Plug.Conn.resp(conn, 200, response)
      end)

      {:ok, media_id} =
        [extname: ".png"]
        |> Briefly.create!()
        |> Media.upload(auth)

      Bypass.expect(bypass, "POST", "/#{auth.whatsapp_number_id}/messages", fn conn ->
        response = ~s<{"messaging_product": "whatsapp", "messages": [{"id": "TESTMESSAGEID"}]}>
        Plug.Conn.resp(conn, 200, response)
      end)

      template_name = "test_url_and_image"
      language = "es_MX"

      header_params = [
        {:image, MediaManager.new_image(media_id)}
      ]

      body_params = [
        {:text, "Mr. Test"}
      ]

      url_button_params = [
        {:text, "some_url_suffix"}
      ]

      quick_reply_button_params = [
        {:payload, "{\"TEST\": \"TESTING\"}"}
      ]

      template =
        template_name
        |> Template.new(language)
        |> Template.add_header(header_params)
        |> Template.add_body(body_params)
        |> Template.add_button(:url, 0, url_button_params)
        |> Template.add_button(:quick_reply, 1, quick_reply_button_params)

      message =
        to
        |> Message.new()
        |> Message.set_type(:template)
        |> Message.add_template(template)

      assert {:ok, %{"messages" => [%{"id" => "TESTMESSAGEID"}]}} = Messages.send(message, auth)
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
