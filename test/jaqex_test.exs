defmodule JaqexTest do
  use ExUnit.Case

  describe "parse/3" do
    for {code, given, expected} <- [
          {".[]", ["hello", "world"], ["hello", "world"]},
          {".[] | {baz: .foo}", [%{foo: 1, bar: 2}, %{foo: 3, bar: 4}],
           [%{"baz" => 1}, %{"baz" => 3}]},
          {"map(select(. >= 2))", [1, 2, 3], [2, 3]},
          {"10 / . * 3", 5, 6}
        ] do
      test "returns #{inspect(expected)} when applying #{code} on #{inspect(given)}" do
        given = Jason.encode!(unquote(Macro.escape(given)))
        actual = Jaqex.parse(given, unquote(code))

        assert actual == {:ok, unquote(Macro.escape(expected))}
      end
    end

    test "returns error tuple when given filter is invalid" do
      assert Jaqex.parse(Jason.encode!([]), "][") == {:error, :invalid_filter}
    end

    test "returns error tuple when given json_doc is invalid" do
      assert Jaqex.parse("[1, 2, 3", ".[]") == {:error, :invalid_json}
    end
  end

  describe "parse_file/3" do
    test "returns results without erroring when file exists" do
      actual = Jaqex.parse_file("priv/test.json", ".[] | {baz: .foo, qux: .bar}")

      assert actual == {:ok, [%{"baz" => 1, "qux" => 2}, %{"baz" => 10, "qux" => 20}]}
    end

    test "returns error tuple when file doesn't exist" do
      actual = Jaqex.parse_file("doesnt-exists.json", ".[]")

      assert actual == {:error, :file_not_found}
    end
  end
end
