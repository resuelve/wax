# WhatsappApi

Cliente para comunicar con el servicio de Whatsapp https://developers.facebook.com/docs/whatsapp

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `whatsapp_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wax, "~> 0.3.0}
  ]
end
```

Setup default parser in `config.ex`

```elixir
config :whatsapp_api, parser: Whatsapp.Parser
```

## Using GenServer Auth

```elixir
defmodule MyApp.Application do
  use Application

  alias Whatsapp.Models.WhatsappProvider

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Whatsapp.Auth.Server, [[
        %WhatsappProvider{
          name: "My company",
          url: "https://wa.io:9090/v1",
          username: "username",
          password: "password"
        }
      ]])
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Now you can use the provider name to authenticate

```elixir
iex> %{"contacts" => [%{"wa_id" => wa_id}] = WhatsappApi.check("5566295500", "My company")
iex> message = MessageOutbound.new(to: wa_id, body: "Hi!")
iex> WhatsappApi.send(message, "My company")
```

## Without GenServer Auth

```elixir
iex> message = MessageOutbound.new(to: "wa_id", body: "Hi!")
iex> auth_header = [{"Authorization", "Bearer #{token}"}]
iex> Whatsapp.Api.Messages.send({"https://wa.io:9090/v1", auth_header, message)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/whatsapp_api](https://hexdocs.pm/whatsapp_api).

