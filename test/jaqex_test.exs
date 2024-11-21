defmodule JaqexTest do
  use ExUnit.Case
  doctest Jaqex

  test "add/2" do
    assert Jaqex.add(1, 2) == 3
  end
end
