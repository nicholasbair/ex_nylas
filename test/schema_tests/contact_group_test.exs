defmodule ExNylas.ContactGroupTest do
  use ExUnit.Case, async: true
  alias ExNylas.ContactGroup

  describe "ContactGroup schema" do
    test "creates a valid contact group with all fields" do
      params = %{
        "grant_id" => "grant_123",
        "group_type" => "system",
        "id" => "group_123",
        "name" => "Family",
        "object" => "contact_group",
        "path" => "/contacts/family"
      }
      changeset = ContactGroup.changeset(%ContactGroup{}, params)
      assert changeset.valid?
      group = Ecto.Changeset.apply_changes(changeset)
      assert group.grant_id == "grant_123"
      assert group.group_type == :system
      assert group.id == "group_123"
      assert group.name == "Family"
      assert group.object == "contact_group"
      assert group.path == "/contacts/family"
    end

    test "validates group_type enum values" do
      valid_types = ["system", "user", "other"]
      for type <- valid_types do
        params = %{"group_type" => type}
        changeset = ContactGroup.changeset(%ContactGroup{}, params)
        assert changeset.valid?, "Type #{type} should be valid"
        group = Ecto.Changeset.apply_changes(changeset)
        assert group.group_type == String.to_atom(type)
      end
    end

    test "rejects invalid group_type values" do
      invalid_types = ["custom", "default", "invalid"]
      for type <- invalid_types do
        params = %{"group_type" => type}
        changeset = ContactGroup.changeset(%ContactGroup{}, params)
        refute changeset.valid?, "Type #{type} should be invalid"
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "grant_id" => nil,
        "group_type" => nil,
        "id" => nil,
        "name" => nil,
        "object" => nil,
        "path" => nil
      }
      changeset = ContactGroup.changeset(%ContactGroup{}, params)
      assert changeset.valid?
      group = Ecto.Changeset.apply_changes(changeset)
      assert group.grant_id == nil
      assert group.group_type == nil
      assert group.id == nil
      assert group.name == nil
      assert group.object == nil
      assert group.path == nil
    end

    test "creates minimal contact group with only id and name" do
      params = %{"id" => "group_123", "name" => "Work"}
      changeset = ContactGroup.changeset(%ContactGroup{}, params)
      assert changeset.valid?
      group = Ecto.Changeset.apply_changes(changeset)
      assert group.id == "group_123"
      assert group.name == "Work"
    end
  end
end
