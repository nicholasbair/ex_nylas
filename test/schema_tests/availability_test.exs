defmodule ExNylas.AvailabilityTest do
  use ExUnit.Case, async: true
  alias ExNylas.Availability

  describe "Availability schema" do
    test "creates a valid availability with all fields" do
      params = %{
        "order" => ["user1@example.com", "user2@example.com"],
        "time_slots" => [
          %{
            "emails" => ["user1@example.com"],
            "start_time" => 1640995200,
            "end_time" => 1640998800
          },
          %{
            "emails" => ["user2@example.com"],
            "start_time" => 1640998800,
            "end_time" => 1641002400
          }
        ]
      }

      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == ["user1@example.com", "user2@example.com"]
      assert length(availability.time_slots) == 2

      [slot1, slot2] = availability.time_slots
      assert slot1.emails == ["user1@example.com"]
      assert slot1.start_time == 1640995200
      assert slot1.end_time == 1640998800
      assert slot2.emails == ["user2@example.com"]
      assert slot2.start_time == 1640998800
      assert slot2.end_time == 1641002400
    end

    test "handles empty time_slots array" do
      params = %{
        "order" => ["user1@example.com"],
        "time_slots" => []
      }

      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == ["user1@example.com"]
      assert availability.time_slots == []
    end

    test "handles time slots with nil timestamps" do
      params = %{
        "order" => ["user1@example.com"],
        "time_slots" => [
          %{
            "emails" => ["user1@example.com"],
            "start_time" => nil,
            "end_time" => nil
          }
        ]
      }

      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      [slot] = availability.time_slots
      assert slot.emails == ["user1@example.com"]
      assert slot.start_time == nil
      assert slot.end_time == nil
    end

    test "handles non-negative integer timestamps" do
      valid_timestamps = [0, 1, 1640995200, 2_147_483_647]
      for timestamp <- valid_timestamps do
        params = %{
          "order" => ["user1@example.com"],
          "time_slots" => [
            %{
              "emails" => ["user1@example.com"],
              "start_time" => timestamp,
              "end_time" => timestamp + 3600
            }
          ]
        }
        changeset = Availability.changeset(%Availability{}, params)
        assert changeset.valid?, "Timestamp #{timestamp} should be valid"
      end
    end

    test "handles nil values gracefully" do
      params = %{
        "order" => nil,
        "time_slots" => []
      }
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == nil
      assert availability.time_slots == []
    end

    test "creates minimal availability with only order" do
      params = %{
        "order" => ["user1@example.com"]
      }
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == ["user1@example.com"]
      assert availability.time_slots == []
    end

    test "handles empty arrays" do
      params = %{
        "order" => [],
        "time_slots" => []
      }
      changeset = Availability.changeset(%Availability{}, params)
      assert changeset.valid?
      availability = Ecto.Changeset.apply_changes(changeset)
      assert availability.order == []
      assert availability.time_slots == []
    end
  end
end
