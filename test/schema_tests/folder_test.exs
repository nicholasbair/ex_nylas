defmodule ExNylas.FolderTest do
  use ExUnit.Case, async: true
  alias ExNylas.Folder

  describe "Folder schema" do
    test "creates a valid folder with all fields" do
      params = %{
        "id" => "folder_123",
        "name" => "Inbox",
        "grant_id" => "grant_456",
        "object" => "folder",
        "parent_id" => "parent_789",
        "background_color" => "#FFFFFF",
        "text_color" => "#000000",
        "attributes" => ["system", "user"],
        "child_count" => 2,
        "total_count" => 100,
        "unread_count" => 5,
        "system_folder" => true
      }

      changeset = Folder.changeset(%Folder{}, params)
      assert changeset.valid?
      folder = Ecto.Changeset.apply_changes(changeset)
      assert folder.id == "folder_123"
      assert folder.name == "Inbox"
      assert folder.grant_id == "grant_456"
      assert folder.object == "folder"
      assert folder.parent_id == "parent_789"
      assert folder.background_color == "#FFFFFF"
      assert folder.text_color == "#000000"
      assert folder.attributes == ["system", "user"]
      assert folder.child_count == 2
      assert folder.total_count == 100
      assert folder.unread_count == 5
      assert folder.system_folder == true
    end

    test "handles nil values gracefully" do
      params = %{
        "id" => "folder_123",
        "name" => nil,
        "grant_id" => nil,
        "object" => nil,
        "parent_id" => nil,
        "background_color" => nil,
        "text_color" => nil,
        "attributes" => nil,
        "child_count" => nil,
        "total_count" => nil,
        "unread_count" => nil,
        "system_folder" => nil
      }
      changeset = Folder.changeset(%Folder{}, params)
      assert changeset.valid?
      folder = Ecto.Changeset.apply_changes(changeset)
      assert folder.id == "folder_123"
      assert folder.name == nil
      assert folder.grant_id == nil
      assert folder.object == nil
      assert folder.parent_id == nil
      assert folder.background_color == nil
      assert folder.text_color == nil
      assert folder.attributes == nil
      assert folder.child_count == nil
      assert folder.total_count == nil
      assert folder.unread_count == nil
      assert folder.system_folder == nil
    end

    test "handles empty arrays" do
      params = %{
        "id" => "folder_123",
        "attributes" => []
      }
      changeset = Folder.changeset(%Folder{}, params)
      assert changeset.valid?
      folder = Ecto.Changeset.apply_changes(changeset)
      assert folder.attributes == []
    end
  end
end
