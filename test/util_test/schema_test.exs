defmodule UtilTest.SchemaTest do
  use ExUnit.Case, async: true
  import ExNylas.Schema.Util

  describe "embedded_changeset" do
    test "casts the params to the struct" do
      struct = %ExNylas.Event.Reminder{}
      params = %{use_default: true}
      changeset = embedded_changeset(struct, params)

      assert changeset.valid?
      assert %{use_default: true} == changeset.changes
    end

    test "ignores fields not defined on the schema" do
      struct = %ExNylas.Event.Reminder{}
      params = %{use_default: true, foo: "bar"}
      changeset = embedded_changeset(struct, params)

      assert changeset.valid?
      assert %{use_default: true} == changeset.changes
    end
  end
end
