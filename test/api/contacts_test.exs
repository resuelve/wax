defmodule Whatsapp.Api.ContactsTest do
  use Whatsapp.Case

  import Mock
  alias Whatsapp.Api.Contacts
  alias Whatsapp.Models.WhatsappProvider

  @auth_header {"Authorization", "Basic token"}

  test "Should check contact" do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          post!: fn _, _, _ ->
            %HTTPoison.Response{
              body: %{
                "contacts" => [
                  %{
                    "input" => "1-631-555-1002",
                    "status" => "invalid"
                  }
                ],
                "meta" => %{}
              }
            }
          end
        ]
      }
    ]) do
      assert Contacts.check("5566295500", @auth_header) == %{
               "contacts" => [
                 %{
                   "input" => "1-631-555-1002",
                   "status" => "invalid"
                 }
               ],
               "meta" => %{}
             }
    end
  end
end
