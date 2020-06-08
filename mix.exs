defmodule WhatsappApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :wax,
      elixirc_paths: elixirc_paths(Mix.env()),
      version: "0.4.5",
      description: "Whatsapp Elixir Client",
      elixir: "~> 1.6",
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
      {:ex_doc, "~> 0.21.0", only: :dev},
      {:httpoison, "~> 1.6.2"},
      {:mock, "~> 0.3.3", only: :test},
      {:timex, "~> 3.3"},
      {:jason, "~> 1.2.1"},
      {:ex_rated, "~> 1.3.1"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Oscar Olivera", "Alfonso Martinez"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/resuelve/whatsapp-api"}
    ]
  end
end
