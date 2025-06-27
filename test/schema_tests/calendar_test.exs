defmodule ExNylas.CalendarTest do
  use ExUnit.Case, async: true
  alias ExNylas.Calendar

  describe "Calendar schema" do
    test "creates a valid calendar with all fields" do
      params = %{
        "description" => "Work calendar",
        "grant_id" => "grant_123",
        "hex_color" => "#FF0000",
        "hex_foreground_color" => "#FFFFFF",
        "id" => "cal_123",
        "is_owned_by_user" => true,
        "is_primary" => false,
        "location" => "Office",
        "metadata" => %{"foo" => "bar"},
        "name" => "Work",
        "object" => "calendar",
        "read_only" => false,
        "timezone" => "America/Los_Angeles",
        "notetaker" => %{"id" => "nt_1", "object" => "notetaker"}
      }

      changeset = Calendar.changeset(%Calendar{}, params)
      assert changeset.valid?
      calendar = Ecto.Changeset.apply_changes(changeset)
      assert calendar.description == "Work calendar"
      assert calendar.grant_id == "grant_123"
      assert calendar.hex_color == "#FF0000"
      assert calendar.hex_foreground_color == "#FFFFFF"
      assert calendar.id == "cal_123"
      assert calendar.is_owned_by_user == true
      assert calendar.is_primary == false
      assert calendar.location == "Office"
      assert calendar.metadata == %{"foo" => "bar"}
      assert calendar.name == "Work"
      assert calendar.object == "calendar"
      assert calendar.read_only == false
      assert calendar.timezone == "America/Los_Angeles"
      assert calendar.notetaker.id == "nt_1"
    end

    test "handles booleans and nil values for boolean fields" do
      for bool <- [true, false, nil] do
        params = %{"is_owned_by_user" => bool, "is_primary" => bool, "read_only" => bool}
        changeset = Calendar.changeset(%Calendar{}, params)
        assert changeset.valid?
        calendar = Ecto.Changeset.apply_changes(changeset)
        assert calendar.is_owned_by_user == bool
        assert calendar.is_primary == bool
        assert calendar.read_only == bool
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "description" => nil,
        "grant_id" => nil,
        "hex_color" => nil,
        "hex_foreground_color" => nil,
        "id" => nil,
        "is_owned_by_user" => nil,
        "is_primary" => nil,
        "location" => nil,
        "metadata" => nil,
        "name" => nil,
        "object" => nil,
        "read_only" => nil,
        "timezone" => nil,
        "notetaker" => nil
      }
      changeset = Calendar.changeset(%Calendar{}, params)
      assert changeset.valid?
      calendar = Ecto.Changeset.apply_changes(changeset)
      assert calendar.description == nil
      assert calendar.grant_id == nil
      assert calendar.hex_color == nil
      assert calendar.hex_foreground_color == nil
      assert calendar.id == nil
      assert calendar.is_owned_by_user == nil
      assert calendar.is_primary == nil
      assert calendar.location == nil
      assert calendar.metadata == nil
      assert calendar.name == nil
      assert calendar.object == nil
      assert calendar.read_only == nil
      assert calendar.timezone == nil
      assert calendar.notetaker == nil
    end

    test "handles empty map for metadata" do
      params = %{"metadata" => %{}}
      changeset = Calendar.changeset(%Calendar{}, params)
      assert changeset.valid?
      calendar = Ecto.Changeset.apply_changes(changeset)
      assert calendar.metadata == %{}
    end

    test "handles missing notetaker" do
      params = %{"id" => "cal_123"}
      changeset = Calendar.changeset(%Calendar{}, params)
      assert changeset.valid?
      calendar = Ecto.Changeset.apply_changes(changeset)
      assert calendar.id == "cal_123"
      assert calendar.notetaker == nil
    end

    test "creates minimal calendar with only id and name" do
      params = %{"id" => "cal_123", "name" => "Personal"}
      changeset = Calendar.changeset(%Calendar{}, params)
      assert changeset.valid?
      calendar = Ecto.Changeset.apply_changes(changeset)
      assert calendar.id == "cal_123"
      assert calendar.name == "Personal"
    end
  end
end
