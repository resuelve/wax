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

  test "Upload a document file", %{bypass: bypass, auth: auth} do
    media_id = "TEST00000000"

    Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/media", fn conn ->
      response = ~s<{"id": "#{media_id}"}>
      Plug.Conn.resp(conn, 200, response)
    end)

    test_file = Briefly.create!(extname: ".pdf")

    assert {:ok, ^media_id} = Media.upload_from_path(test_file, auth)
  end

  test "Uploading a document with no extension should return an error", %{auth: auth} do
    test_file = Briefly.create!(extname: "")

    assert {:error, error} = Media.upload_from_path(test_file, auth)
    assert String.contains?(error, "extension")
  end

  test "Upload a document file from a binary", %{bypass: bypass, auth: auth} do
    media_id = "TEST00000000"

    Bypass.expect_once(bypass, "POST", "/#{auth.whatsapp_number_id}/media", fn conn ->
      response = ~s<{"id": "#{media_id}"}>
      Plug.Conn.resp(conn, 200, response)
    end)

    test_file = Briefly.create!(extname: ".pdf")
    binary_data = File.read!(test_file)

    assert {:ok, ^media_id} = Media.upload_binary(binary_data, test_file, auth)
  end

  test "Uploading a document from a binary with no extension should return an error", %{
    auth: auth
  } do
    test_file = Briefly.create!(extname: "")
    binary_data = File.read!(test_file)

    assert {:error, error} = Media.upload_binary(binary_data, test_file, auth)
    assert String.contains?(error, "extension")
  end
end
