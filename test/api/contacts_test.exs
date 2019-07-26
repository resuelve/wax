defmodule Whatsapp.Api.ContactsTest do
  use Whatsapp.Case

  import Mock
  alias Whatsapp.Api.Contacts
  alias Whatsapp.Models.WhatsappProvider

  test "Should check contact", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, _, _, _ ->
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
      assert Contacts.check(token_info, "5566295500") == %{
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
