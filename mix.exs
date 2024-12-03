defmodule Jaqex.MixProject do
  use Mix.Project

  @source_url "https://github.com/shaolang/jaqex"
  @version "0.1.1"

  def project do
    [
      app: :jaqex,
      aliases: aliases(),
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

  defp aliases do
    [
      "gen.checksums": &gen_checksums/1,
      "test.local": &test_local/1,
      "test.watch.local": &test_watch_local/1
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.35", only: :dev, runtime: false},
      {:jason, "~> 1.4"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:rustler, "~> 0.35", optional: true, runtime: false},
      {:rustler_precompiled, "~> 0.8"}
    ]
  end

  defp docs do
    [
      main: "readme",
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
      files: [
        "README.md",
        "checksum-*.exs",
        "lib",
        "mix.exs",
        "native/jaqex/*.toml",
        "native/jaqex/.cargo",
        "native/jaqex/.gitignore",
        "native/jaqex/Cargo.lock",
        "native/jaqex/README.md",
        "native/jaqex/src",
        "priv/test.json"
      ]
    ]
  end

  defp gen_checksums(_) do
    System.cmd(
      "mix",
      ["rustler_precompiled.download", "Jaqex", "--all", "--print"],
      into: IO.stream(),
      env: [{"FORCE_JAQEX_BUILD", "true"}]
    )
  end

  defp run_tests(cmd) do
    System.cmd(
      "mix",
      [cmd],
      into: IO.stream(),
      env: [{"FORCE_JAQEX_BUILD", "true"}]
    )
  end

  defp test_local(_), do: run_tests("test")
  defp test_watch_local(_), do: run_tests("test.watch")
end
