defmodule JaqexTest do
  use ExUnit.Case
  doctest Jaqex

  describe "filter/3" do
    for {code, given, expected} <- [
          {".[]", ["hello", "world"], ["hello", "world"]},
          {".[] | {baz: .foo}", [%{foo: 1, bar: 2}, %{foo: 3, bar: 4}],
           [%{"baz" => 1}, %{"baz" => 3}]},
          {"map(select(. >= 2))", [1, 2, 3], [2, 3]},
          {"10 / . * 3", 5, 6}
        ] do
      test "returns #{inspect(expected)} when applying #{code} on #{inspect(given)}" do
        given = Jason.encode!(unquote(Macro.escape(given)))
        actual = Jaqex.filter(given, unquote(code))

        assert actual == {:ok, unquote(Macro.escape(expected))}
      end
    end

    test "returns error tuple when given filter is invalid" do
      assert Jaqex.filter(Jason.encode!([]), "][") == {:error, :invalid_filter}
    end

    test "returns error tuple when given json_doc is invalid" do
      assert Jaqex.filter("[1, 2, 3", ".[]") == {:error, :invalid_json}
    end

    test "supports loading external jq files from given path" do
      given = Jason.encode!(["fooBar", "barBaz"])
      filter = "import \"t\" as t; .[] | t::snake_case(.)"
      actual = Jaqex.filter(given, filter, "priv")

      assert actual == {:ok, ["foo_bar", "bar_baz"]}
    end
  end

  describe "filter!/3" do
    test "returns (success) result not wrapped in tuple" do
      assert Jaqex.filter!("[1,2,3]", ".[]") == [1, 2, 3]
    end

    test "throws an error when given code is invalid" do
      assert_raise ErlangError, fn ->
        Jaqex.filter!("[1,2]", "][")
      end
    end
  end

  describe "filter_file/3" do
    test "returns results without erroring when file exists" do
      actual = Jaqex.filter_file("priv/test.json", ".[] | {baz: .foo, qux: .bar}")

      assert actual == {:ok, [%{"baz" => 1, "qux" => 2}, %{"baz" => 10, "qux" => 20}]}
    end

    test "returns error tuple when file doesn't exist" do
      actual = Jaqex.filter_file("doesnt-exists.json", ".[]")

      assert actual == {:error, :file_not_found}
    end
  end

  describe "filter_file!/3" do
    test "returns (success) result not wrapped in tuple" do
      assert Jaqex.filter_file!("priv/test.json", ".[] | {foo}") == [%{"foo" => 1}, %{"foo" => 10}]
    end

    test "throws an error when given code is invalid" do
      assert_raise ErlangError, fn ->
        Jaqex.filter_file!("priv/test.json", ".[.foo]")
      end
    end
  end
end
