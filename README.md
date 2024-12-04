# Jaqex
Elixir wrapper for [jaq](https://github.com/01mf02/jaq), a [jq](https://jqlang.github.io/jq/)
clone focused on correctness, speed, and simplicity implemented in Rust.

Unlike other jq wrappers, this doesn't require jq to be installed/available in `$PATH`:
Jaqex uses [rustler](https://hexdocs.pm/rustler/) to implement the NIFs to jaq.
And because Jaqex uses jaq, certain jq features like SQL-style operators aren't available.
Please refer to [jaq's README "differences between jq and jaq"][diff]
for more information. Despite such differences, jaq should still be useful in most
scenarios, especially in the succintness in filtering/transforming JSON.

The following demonstrates the difference between using Elixir/Jason and Jaqex. Assuming
we have transform the following JSON doc from this:

```json
{
    "ticker": "AAPL",
    "adjusted": true,
    "prices": [
        {"o": 229.52, "h": 229.65, "l": 223.74, "c": 226.21, "d": "2024-10-01"},
        {"o": 225.89, "h": 227.37, "l": 223.02, "c": 226.78, "d": "2024-10-02"}
    ]
}
```

To this:

```elixir
[
    %{
        "open" => 229.52, "high": 229.65, "low" => 223.74, "close" => 226.21,
        "date" => "2024-10-01", "ticker" => "AAPL", "adjusted": true
    },
    %{
        "open" => 225.89, "high": 227.37, "low" => 223.02, "close" => 226.78,
        "date" => "2024-10-02", "ticker" => "AAPL", "adjusted": true
   },
]
```

The following shows how it's done using Elixir and Jason:


```elixir
doc = Jason.decode!(json_string)    # assuming the contents are in json_string
renames = %{"o" => "open", "h" => "high", "l" => "low", "c" => "close", "d" => "date"}
additions = Map.take(doc, ["ticker", "adjusted"])

result =
    doc["prices"]
    |> Stream.map(fn m ->
        renames |> Stream.map(fn {original, new_name} -> {new_name, m[original]} end)
    end)
    |> Stream.map(&Map.new/1)
    |> Enum.map(&Map.merge(&1, additions))
```

Comparing that with using Jaqex:

```elixir
result = Jaqex.filter!(
    json_string,
    "[. as $root | .prices[] |
        {open: .o, high: .h, low: .l, close: .c,
         date: .d, ticker: $root.ticker, adjusted: $root.adjusted}
    ]"
)
```

Jaq/jq filters make transformations as such straightforward.

[diff]: https://github.com/01mf02/jaq/blob/main/README.md#differences-between-jq-and-jaq

## Installation

Add `jaqex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jaqex, "~> 0.1.1"}
  ]
end
```

## Copyright and License
Copyright© 2024, Shaolang Ai

Distributed under the MIT License
