defmodule Whatsapp.Auth.ServerTest do
  use ExUnit.Case
  doctest WhatsappApi

  import Mock
  alias Whatsapp.Auth.Server
  alias Whatsapp.Models.WhatsappProvider

  test "Should get auth header" do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          post!: fn _, _, _ ->
            %HTTPoison.Response{
              body: %{
                "users" => [
                  %{
                    "token" => "dXNlcm5hbWU6cGFzc3dvcmQ=",
                    "expires_after" => "2018-03-01 15:29:26+00:00"
                  }
                ]
              }
            }
          end
        ]
      }
    ]) do
      providers = [
        %WhatsappProvider{
          name: "My company",
          username: "username",
          password: "password",
          url: "https://wa.io:9090/v1"
        },
        %WhatsappProvider{
          name: "",
          username: "",
          password: "",
          url: ""
        }
      ]

      {:ok, _pid} = Server.start_link(providers)
      {url, auth_header} = Server.get_token_info("My company")

      assert url == "https://wa.io:9090/v1"
      assert auth_header == {"Authorization", "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="}
    end
  end
end
