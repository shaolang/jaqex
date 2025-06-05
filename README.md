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
    "data": [
      [229.52, 229.65, 223.74, 226.21, "2024-10-01"],
      [225.89, 227.37, 223.02, 226.78, "2024-10-02"]
    ],
    "fields": [
      {"field": "open", "type": "float"},
      {"field": "high", "type": "float"},
      {"field": "low",  "type": "float"},
      {"field": "close","type": "float"},
      {"field": "date", "type": "date"}
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

Assuming the positions of the values aren't fixed and there may be additions to
the fields and values, the following shows how it's done using Elixir and Jason:

```elixir
doc = Jason.decode!(json_string)    # assuming the contents are in json_string
keys = doc["fields"] |> Enum.map(&Map.get(&1, "field"))
result =
    doc["data"]
    |> Stream.map(&Enum.zip(keys, &1))
    |> Stream.map(&Map.new/1)
    |> Enum.map(&Map.merge(&1, additions))
```

Comparing that with using Jaqex:

```elixir
result = Jaqex.filter!(
    json_string,
    "[. as $root
      | .data[]
      | [[$root.fields[] | .field], .]
      | transpose
      | map({key: .[0], value: .[1]})
      | from_entries
      | . + {ticker: $root.ticker, adjusted: $root.adjusted}
    ]"
)
```

Jaq/jq filters make transformations as such straightforward (when you know jq-lang).
Because Jaq's transformations are done in Rust, memory usage is much lower and transformation
faster; native Elixir version requires creating multiple (interim/throwaway) lists and
maps (`keys`, `additions`, the maps from `&Enum.zip(keys, &1)` and `&Map.new/1`).

## Installation

Add `jaqex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jaqex, "~> 0.1.3"}
  ]
end
```

## Copyright and License
Copyright © 2024, Shaolang Ai

Distributed under the MIT License

[diff]: https://github.com/01mf02/jaq/blob/main/README.md#differences-between-jq-and-jaq
