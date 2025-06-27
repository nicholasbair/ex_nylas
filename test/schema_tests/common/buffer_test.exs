defmodule ExNylas.BufferTest do
  use ExUnit.Case, async: true
  alias ExNylas.Buffer

  describe "Buffer schema" do
    test "creates a valid buffer with all fields" do
      params = %{
        "after" => 1000,
        "before" => 500
      }
      changeset = Buffer.changeset(%Buffer{}, params)
      assert changeset.valid?
      buffer = Ecto.Changeset.apply_changes(changeset)
      assert buffer.after == 1000
      assert buffer.before == 500
    end

    test "handles nil values for all fields" do
      params = %{
        "after" => nil,
        "before" => nil
      }
      changeset = Buffer.changeset(%Buffer{}, params)
      assert changeset.valid?
      buffer = Ecto.Changeset.apply_changes(changeset)
      assert buffer.after == nil
      assert buffer.before == nil
    end

    test "handles zero values" do
      params = %{
        "after" => 0,
        "before" => 0
      }
      changeset = Buffer.changeset(%Buffer{}, params)
      assert changeset.valid?
      buffer = Ecto.Changeset.apply_changes(changeset)
      assert buffer.after == 0
      assert buffer.before == 0
    end

    test "handles large integer values" do
      params = %{
        "after" => 999999999,
        "before" => 123456789
      }
      changeset = Buffer.changeset(%Buffer{}, params)
      assert changeset.valid?
      buffer = Ecto.Changeset.apply_changes(changeset)
      assert buffer.after == 999999999
      assert buffer.before == 123456789
    end

    test "creates minimal buffer with only after" do
      params = %{"after" => 100}
      changeset = Buffer.changeset(%Buffer{}, params)
      assert changeset.valid?
      buffer = Ecto.Changeset.apply_changes(changeset)
      assert buffer.after == 100
      assert buffer.before == nil
    end

    test "creates minimal buffer with only before" do
      params = %{"before" => 200}
      changeset = Buffer.changeset(%Buffer{}, params)
      assert changeset.valid?
      buffer = Ecto.Changeset.apply_changes(changeset)
      assert buffer.after == nil
      assert buffer.before == 200
    end

    test "creates empty buffer" do
      params = %{}
      changeset = Buffer.changeset(%Buffer{}, params)
      assert changeset.valid?
      buffer = Ecto.Changeset.apply_changes(changeset)
      assert buffer.after == nil
      assert buffer.before == nil
    end

    test "handles string integer values" do
      params = %{
        "after" => "1000",
        "before" => "500"
      }
      changeset = Buffer.changeset(%Buffer{}, params)
      assert changeset.valid?
      buffer = Ecto.Changeset.apply_changes(changeset)
      assert buffer.after == 1000
      assert buffer.before == 500
    end

    test "handles negative integers (should be valid as per schema)" do
      params = %{
        "after" => -100,
        "before" => -200
      }
      changeset = Buffer.changeset(%Buffer{}, params)
      # Note: The schema specifies non_neg_integer() but the changeset doesn't validate this
      # This test documents the current behavior
      assert changeset.valid?
      buffer = Ecto.Changeset.apply_changes(changeset)
      assert buffer.after == -100
      assert buffer.before == -200
    end
  end
end
