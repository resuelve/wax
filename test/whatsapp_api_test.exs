defmodule WhatsappApiTest do
  use ExUnit.Case
  doctest WhatsappApi

  test "greets the world" do
    assert WhatsappApi.hello() == :world
  end
end
