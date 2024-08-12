defmodule ExNylasTest.MapOrList do
  use ExUnit.Case
  alias ExNylas.Type.MapOrList

  describe "type/0" do
    test "returns :any" do
      assert MapOrList.type() == :any
    end
  end

  describe "cast/1" do
    test "returns {:ok, data} when given a map" do
      data = %{key: "value"}
      assert MapOrList.cast(data) == {:ok, data}
    end

    test "returns {:ok, data} when given a list" do
      data = [1, 2, 3]
      assert MapOrList.cast(data) == {:ok, data}
    end

    test "returns :error when given a non-map or non-list" do
      data = "string"
      assert MapOrList.cast(data) == :error
    end
  end

  describe "load/1" do
    test "returns {:ok, data} when given a map" do
      data = %{key: "value"}
      assert MapOrList.load(data) == {:ok, data}
    end

    test "returns {:ok, data} when given a list" do
      data = [1, 2, 3]
      assert MapOrList.load(data) == {:ok, data}
    end
  end

  describe "dump/1" do
    test "returns {:ok, data} when given a map" do
      data = %{key: "value"}
      assert MapOrList.dump(data) == {:ok, data}
    end

    test "returns {:ok, data} when given a list" do
      data = [1, 2, 3]
      assert MapOrList.dump(data) == {:ok, data}
    end
  end
end
