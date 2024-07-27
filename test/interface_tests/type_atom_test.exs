defmodule ExNylasTest.Type.AtomTest do
  use ExUnit.Case
  alias ExNylas.Type.Atom

  describe "type/0" do
    test "returns :string" do
      assert Atom.type() == :string
    end
  end

  describe "cast/1" do
    test "returns {:ok, value} when given an atom" do
      value = :test_atom
      assert Atom.cast(value) == {:ok, value}
    end

    test "returns :error when given a non-atom" do
      value = "string"
      assert Atom.cast(value) == :error
    end
  end

  describe "load/1" do
    test "returns {:ok, atom} when given a string that matches an existing atom" do
      value = "test_atom"
      existing_atom = String.to_existing_atom(value)
      assert Atom.load(value) == {:ok, existing_atom}
    end

    test "raises ArgumentError when given a string that does not match an existing atom" do
      value = "non_existent_atom"
      assert_raise ArgumentError, fn ->
        Atom.load(value)
      end
    end
  end

  describe "dump/1" do
    test "returns {:ok, string} when given an atom" do
      value = :test_atom
      assert Atom.dump(value) == {:ok, to_string(value)}
    end

    test "returns :error when given a non-atom" do
      value = "string"
      assert Atom.dump(value) == :error
    end
  end
end
