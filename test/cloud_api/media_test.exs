defmodule Wax.CloudAPI.MediaTest do
  use Whatsapp.Case

  alias Wax.CloudAPI.{Auth, Media}

  setup do
    bypass = Bypass.open()
    Application.put_env(:wax, :cloud_api, url: "http://localhost:#{bypass.port}", version: "")

    test_to_number = "TEST550000000001"
    test_wa_number_id = "TEST0000000001"
    test_token = "TESTTOKEN999"

    auth = Auth.new(test_wa_number_id, test_token)

    {:ok, bypass: bypass, auth: auth, to: test_to_number}
  end

  test "Downloading a media file", %{bypass: bypass, auth: auth} do
    url = "localhost:#{bypass.port}/test-download-media"
    media_id = "TEST00000000"

    Bypass.expect_once(bypass, "GET", "/#{media_id}", fn conn ->
      response = ~s<{"url": "#{url}"}>
      Plug.Conn.resp(conn, 200, response)
    end)

    Bypass.expect_once(bypass, "GET", "/test-download-media", fn conn ->
      response = <<0>>
      Plug.Conn.resp(conn, 200, response)
    end)

    assert {:ok, binary_data} = Media.download(media_id, auth)
    assert is_bitstring(binary_data)
  end

  test "Upload a document file", %{bypass: bypass, auth: auth} do
    media_id = "TEST00000000"

    Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/media", fn conn ->
      response = ~s<{"id": "#{media_id}"}>
      Plug.Conn.resp(conn, 200, response)
    end)

    test_file_path = Briefly.create!(extname: ".pdf")

    assert {:ok, ^media_id} = Media.upload_from_path(test_file_path, auth)
  end

  test "Uploading a document with no extension should return an error", %{auth: auth} do
    test_file_path = Briefly.create!(extname: "")

    assert {:error, error} = Media.upload_from_path(test_file_path, auth)
    assert String.contains?(error, "extension")
  end

  test "Upload a document file from a binary", %{bypass: bypass, auth: auth} do
    media_id = "TEST00000000"

    Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/media", fn conn ->
      response = ~s<{"id": "#{media_id}"}>
      Plug.Conn.resp(conn, 200, response)
    end)

    test_file_path = Briefly.create!(extname: ".pdf")
    binary_data = File.read!(test_file_path)

    assert {:ok, ^media_id} = Media.upload_binary(binary_data, test_file_path, auth)
  end

  test "Uploading a document from a binary with no extension should return an error", %{
    auth: auth
  } do
    test_file_path = Briefly.create!(extname: "")
    binary_data = File.read!(test_file_path)

    assert {:error, error} = Media.upload_binary(binary_data, test_file_path, auth)
    assert String.contains?(error, "extension")
  end
end
