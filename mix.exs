defmodule Jaqex.MixProject do
  use Mix.Project

  def project do
    [
      app: :jaqex,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: []

  defp deps do
    [
      {:rustler, "~> 0.35", runtime: false}
    ]
  end
end
