defmodule ExNylas.RoomResourceTest do
  use ExUnit.Case, async: true
  alias ExNylas.RoomResource

  describe "RoomResource schema" do
    test "creates a valid room resource with all fields" do
      params = %{
        "building" => "Main Building",
        "capacity" => 20,
        "email" => "conference-room-a@company.com",
        "floor_name" => "Ground Floor",
        "floor_number" => 1,
        "floor_section" => "East Wing",
        "grant_id" => "grant_123",
        "object" => "room_resource"
      }
      changeset = RoomResource.changeset(%RoomResource{}, params)
      assert changeset.valid?
      room = Ecto.Changeset.apply_changes(changeset)
      assert room.building == "Main Building"
      assert room.capacity == 20
      assert room.email == "conference-room-a@company.com"
      assert room.floor_name == "Ground Floor"
      assert room.floor_number == 1
      assert room.floor_section == "East Wing"
      assert room.grant_id == "grant_123"
      assert room.object == "room_resource"
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "building" => nil,
        "capacity" => nil,
        "email" => nil,
        "floor_name" => nil,
        "floor_number" => nil,
        "floor_section" => nil,
        "grant_id" => nil,
        "object" => nil
      }
      changeset = RoomResource.changeset(%RoomResource{}, params)
      assert changeset.valid?
      room = Ecto.Changeset.apply_changes(changeset)
      assert room.building == nil
      assert room.capacity == nil
      assert room.email == nil
      assert room.floor_name == nil
      assert room.floor_number == nil
      assert room.floor_section == nil
      assert room.grant_id == nil
      assert room.object == nil
    end

    test "handles integer values for capacity and floor_number" do
      valid_integers = [0, 1, 10, 100, 1000]
      for integer <- valid_integers do
        params = %{"capacity" => integer, "floor_number" => integer}
        changeset = RoomResource.changeset(%RoomResource{}, params)
        assert changeset.valid?, "Integer #{integer} should be valid"
        room = Ecto.Changeset.apply_changes(changeset)
        assert room.capacity == integer
        assert room.floor_number == integer
      end
    end

    test "handles negative integers for floor_number" do
      params = %{"floor_number" => -1}
      changeset = RoomResource.changeset(%RoomResource{}, params)
      assert changeset.valid?
      room = Ecto.Changeset.apply_changes(changeset)
      assert room.floor_number == -1
    end

    test "creates minimal room resource with only email" do
      params = %{"email" => "room@company.com"}
      changeset = RoomResource.changeset(%RoomResource{}, params)
      assert changeset.valid?
      room = Ecto.Changeset.apply_changes(changeset)
      assert room.email == "room@company.com"
    end
  end
end
