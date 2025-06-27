defmodule ExNylas.CommonAvailabilityTest do
  use ExUnit.Case, async: true
  alias ExNylas.Availability

  describe "Availability schema" do
    test "creates a valid availability with all fields" do
      params = %{
        "order" => ["user1@example.com", "user2@example.com"],
        "time_slots" => [
          %{
            "emails" => ["user1@example.com", "user2@example.com"],
            "end_time" => 1704067200,
            "start_time" => 1704063600
          },
          %{
            "emails" => ["user1@example.com"],
            "end_time" => 1704153600,
            "start_time" => 1704150000
          }
        ]
      }
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == ["user1@example.com", "user2@example.com"]
      assert length(availability.time_slots) == 2

      [first_slot, second_slot] = availability.time_slots
      assert first_slot.emails == ["user1@example.com", "user2@example.com"]
      assert first_slot.end_time == 1704067200
      assert first_slot.start_time == 1704063600
      assert second_slot.emails == ["user1@example.com"]
      assert second_slot.end_time == 1704153600
      assert second_slot.start_time == 1704150000
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "order" => nil,
        "time_slots" => nil
      }
      changeset = Availability.changeset(%Availability{}, params)
      refute changeset.valid?
    end

    test "handles empty order array" do
      params = %{"order" => []}
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == []
    end

    test "handles empty time_slots array" do
      params = %{"time_slots" => []}
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.time_slots == []
    end

    test "handles time slots with partial fields" do
      params = %{
        "time_slots" => [
          %{
            "emails" => ["user@example.com"],
            "start_time" => 1704063600
          },
          %{
            "end_time" => 1704153600
          }
        ]
      }
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert length(availability.time_slots) == 2

      [first_slot, second_slot] = availability.time_slots
      assert first_slot.emails == ["user@example.com"]
      assert first_slot.start_time == 1704063600
      assert first_slot.end_time == nil
      assert second_slot.emails == nil
      assert second_slot.start_time == nil
      assert second_slot.end_time == 1704153600
    end

    test "handles empty emails array in time slot" do
      params = %{
        "time_slots" => [
          %{
            "emails" => [],
            "start_time" => 1704063600,
            "end_time" => 1704067200
          }
        ]
      }
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert length(availability.time_slots) == 1
      assert availability.time_slots |> List.first() |> Map.get(:emails) == []
    end

    test "handles zero time values" do
      params = %{
        "time_slots" => [
          %{
            "start_time" => 0,
            "end_time" => 0
          }
        ]
      }
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert length(availability.time_slots) == 1
      slot = List.first(availability.time_slots)
      assert slot.start_time == 0
      assert slot.end_time == 0
    end

    test "creates minimal availability with only order" do
      params = %{"order" => ["user@example.com"]}
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == ["user@example.com"]
      assert availability.time_slots == []
    end

    test "creates minimal availability with only time_slots" do
      params = %{
        "time_slots" => [
          %{
            "emails" => ["user@example.com"],
            "start_time" => 1704063600,
            "end_time" => 1704067200
          }
        ]
      }
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == nil
      assert length(availability.time_slots) == 1
    end

    test "creates empty availability" do
      params = %{}
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == nil
      assert availability.time_slots == []
    end
  end
end
