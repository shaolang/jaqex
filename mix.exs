defmodule Jaqex.MixProject do
  use Mix.Project

  @source_url "https://github.com/shaolang/jaqex"
  @version "0.1.0"

  def project do
    [
      app: :jaqex,
      deps: deps(),
      description: "Wrapper for Jaq (a jq clone focused on correctness, speed, and simplicity)",
      docs: docs(),
      elixir: "~> 1.16",
      package: package(),
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  def application, do: []

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:rustler, "~> 0.35", optional: true, runtime: false},
      {:rustler_precompiled, "~> 0.8"}
    ]
  end

  defp docs do
    [
      main: "README",
      name: "Jaqex",
      source_ref: "v#{@version}",
      canonical: "https://hexdocs.pm/jaqex",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      maintainers: ["Shaolang Ai"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/shaolang/jaqex"},
      files: ["lib", "mix.exs", "README.md", "navtive", "checksum-*.exs"],
    ]
  end
end
