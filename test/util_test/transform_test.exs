defmodule ExNylasTest.Transform do
  use ExUnit.Case, async: true

  test "transform returns nil if it receives nil" do
    assert ExNylas.Transform.transform({:ok, nil}) == {:ok, nil}
  end

  test "transform converts the API response into the provided struct" do
    assert ExNylas.Transform.transform({:ok, %{"id" => "1234"}}, ExNylas.Label) == {:ok, %ExNylas.Label{id: "1234"}}
  end

  test "transform converts the API response into the provided structs" do
    assert ExNylas.Transform.transform({:ok, [%{"id" => "1234"}, %{"id" => "5678"}]}, ExNylas.Label) == {:ok, [%ExNylas.Label{id: "1234"}, %ExNylas.Label{id: "5678"}]}
  end
end
