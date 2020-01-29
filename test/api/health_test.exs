defmodule Whatsapp.Api.HealthTest do
  use Whatsapp.Case

  import Mock
  alias Whatsapp.Api.Health

  test "Should get health", %{token_info: token_info} do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          rate_limit_request: fn _, _, _ ->
            %HTTPoison.Response{body: %{}}
          end
        ]
      }
    ]) do
      assert Health.get_summary(token_info) == %{}
    end
  end
end
