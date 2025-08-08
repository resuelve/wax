defmodule WhatsappApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :wax,
      elixirc_paths: elixirc_paths(Mix.env()),
      version: "1.1.0",
      description: "Whatsapp Elixir Client",
      elixir: "~> 1.16",
      package: package(),
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
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.38.0", only: :dev},
      {:httpoison, "~> 2.2.0"},
      {:mock, "~> 0.3.9", only: :test},
      {:timex, "~> 3.7"},
      {:jason, "~> 1.4.4"},
      {:ex_rated, "~> 2.1.0"},
      {:bypass, "~> 2.1", only: :test},
      {:briefly, "~> 0.5.1", only: :test},
      {:mime, "~> 2.0"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["John Lopez", "Alfonso Martinez"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/resuelve/whatsapp-api"}
    ]
  end
end
