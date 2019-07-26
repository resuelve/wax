defmodule Whatsapp.Case do
  use ExUnit.CaseTemplate

  setup do
    {
      :ok,
      token_info: {"https://wa.io/v1", {"Authorization", "Bearer token"}}
    }
  end
end
