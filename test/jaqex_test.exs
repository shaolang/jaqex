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
end
