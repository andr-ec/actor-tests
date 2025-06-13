defmodule ElixirBenchmarkTest do
  use ExUnit.Case
  doctest ElixirBenchmark

  test "greets the world" do
    assert ElixirBenchmark.hello() == :world
  end
end
