# Jaqex
Elixir wrapper for [jaq](https://github.com/01mf02/jaq), a [jq](https://jqlang.github.io/jq/)
clone focused on correctness, speed, and simplicity implemented in Rust.

Unlike other jq wrappers, this doesn't require jq to be installed/available in `$PATH`:
Jaqex uses [rustler](https://hexdocs.pm/rustler/) to implement the NIFs to jaq.
And because Jaqex uses jaq, certain jq features like SQL-style operators aren't available.
Please refer to [jaq's README "differences between jq and jaq"][diff]
for more information.

[diff]: https://github.com/01mf02/jaq/blob/main/README.md#differences-between-jq-and-jaq

## Installation

Add `jaqex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jaqex, "~> 0.1.0"}
  ]
end
```

## Copyright and License
Copyright© 2024, Shaolang Ai

Distributed under the MIT License
