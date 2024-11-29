defmodule Jaqex.MixProject do
  use Mix.Project

  def project do
    [
      app: :jaqex,
      deps: deps(),
      elixir: "~> 1.16",
      source_url: "https://github.com/shaolang/jaqex",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
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
end
