defmodule WhatsappApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :whatsapp_api,
      elixirc_paths: elixirc_paths(Mix.env),
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.3", override: true},
      {:mock, "~> 0.3.3", only: :test},
      {:timex, "~> 3.3"},
      {:poison, "~> 3.1"}
    ]
  end
end
