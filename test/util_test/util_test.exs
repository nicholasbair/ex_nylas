defmodule ExNylas.UtilTest do
  use ExUnit.Case
  import ExNylas.Util

  test "indifferent_get returns the value for an existing key in a map" do
    map = %{"foo" => "bar", :baz => "qux"}

    assert indifferent_get(map, :baz) == "qux"
  end

  test "indifferent_get returns the value for an existing key in a keyword list" do
    list = [{:foo, "bar"}, {:baz, "qux"}]

    assert indifferent_get(list, :foo) == "bar"
  end

  test "indifferent_get returns nil for a non-existing key if no default is provided" do
    map = %{"foo" => "bar", :baz => "qux"}

    assert indifferent_get(map, "non_existing") == nil
  end

  test "indifferent_get returns the default value for a non-existing key" do
    map = %{"foo" => "bar", :baz => "qux"}

    assert indifferent_get(map, "non_existing", "default") == "default"
  end

  test "indifferent_put_new adds a new key-value pair to the map" do
    map = %{"foo" => "bar"}

    new_map = indifferent_put_new(map, :baz, "qux")

    assert new_map == %{"foo" => "bar", :baz => "qux"}
  end

  test "indifferent_put_new does not replace the value for an existing key" do
    map = %{"foo" => "bar"}

    new_map = indifferent_put_new(map, "foo", "updated")

    assert new_map == map
  end
end
