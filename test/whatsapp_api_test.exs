defmodule WhatsappApiTest do
  use ExUnit.Case
  doctest WhatsappApi

  import Mock
  alias Whatsapp.Auth.Server
  alias Whatsapp.Models.WhatsappProvider

  test "Should get auth header" do
    with_mocks([{
      WhatsappApiRequest,
      [],
      [
        post!: fn (_, _, _) ->
          %HTTPoison.Response{
            body: %{
              "users" => [%{
                "token" => "dXNlcm5hbWU6cGFzc3dvcmQ=",
                "expires_after" => "2018-03-01 15:29:26+00:00"
              }]
            }
          }
        end
      ]
    }]) do
      provider = %WhatsappProvider{
        name: "My company",
        username: "username",
        password: "password"
      }

      {:ok, pid} = Server.start_link([provider])
      auth_header = WhatsappApi.get_auth_header("My company")

      assert auth_header == {"Authorization", "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="}
    end
  end
end
