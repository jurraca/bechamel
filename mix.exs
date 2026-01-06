defmodule Bechamel.MixProject do
  use Mix.Project

  def project do
    [
      app: :bechamel,
      version: "1.0.0",
      elixir: "~> 1.15",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      name: "Bechamel",
      source_url: "https://github.com/jurraca/bechamel",
      deps: deps()
    ]
  end

  defp description() do
    "This is an implementation of BIP-0173 or bech32. A fork of bech32-elixir."
  end

  defp package() do
    [
      name: "bechamel",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jurraca/bechamel"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end
end
