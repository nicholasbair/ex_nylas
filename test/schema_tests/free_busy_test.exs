defmodule ExNylas.FreeBusyTest do
  use ExUnit.Case, async: true
  alias ExNylas.FreeBusy

  describe "FreeBusy schema" do
    test "creates a valid free/busy with all fields" do
      params = %{
        "email" => "user@example.com",
        "object" => "free_busy",
        "time_slots" => [
          %{
            "end_time" => 1640998800,
            "object" => "time_slot",
            "start_time" => 1640995200,
            "status" => "busy"
          },
          %{
            "end_time" => 1641002400,
            "object" => "time_slot",
            "start_time" => 1640998800,
            "status" => "free"
          }
        ]
      }
      changeset = FreeBusy.changeset(%FreeBusy{}, params)
      assert changeset.valid?
      free_busy = Ecto.Changeset.apply_changes(changeset)
      assert free_busy.email == "user@example.com"
      assert free_busy.object == "free_busy"
      assert length(free_busy.time_slots) == 2

      [slot1, slot2] = free_busy.time_slots
      assert slot1.end_time == 1640998800
      assert slot1.object == "time_slot"
      assert slot1.start_time == 1640995200
      assert slot1.status == "busy"
      assert slot2.end_time == 1641002400
      assert slot2.object == "time_slot"
      assert slot2.start_time == 1640998800
      assert slot2.status == "free"
    end

    test "handles empty time_slots array" do
      params = %{
        "email" => "user@example.com",
        "object" => "free_busy",
        "time_slots" => []
      }
      changeset = FreeBusy.changeset(%FreeBusy{}, params)
      assert changeset.valid?
      free_busy = Ecto.Changeset.apply_changes(changeset)
      assert free_busy.email == "user@example.com"
      assert free_busy.object == "free_busy"
      assert free_busy.time_slots == []
    end

    test "handles time slots with nil timestamps" do
      params = %{
        "email" => "user@example.com",
        "object" => "free_busy",
        "time_slots" => [
          %{
            "end_time" => nil,
            "object" => "time_slot",
            "start_time" => nil,
            "status" => "unknown"
          }
        ]
      }
      changeset = FreeBusy.changeset(%FreeBusy{}, params)
      assert changeset.valid?
      free_busy = Ecto.Changeset.apply_changes(changeset)
      [slot] = free_busy.time_slots
      assert slot.end_time == nil
      assert slot.object == "time_slot"
      assert slot.start_time == nil
      assert slot.status == "unknown"
    end

    test "handles non-negative integer timestamps" do
      valid_timestamps = [0, 1, 1640995200, 2_147_483_647]
      for timestamp <- valid_timestamps do
        params = %{
          "email" => "user@example.com",
          "object" => "free_busy",
          "time_slots" => [
            %{
              "end_time" => timestamp + 3600,
              "object" => "time_slot",
              "start_time" => timestamp,
              "status" => "busy"
            }
          ]
        }
        changeset = FreeBusy.changeset(%FreeBusy{}, params)
        assert changeset.valid?, "Timestamp #{timestamp} should be valid"
      end
    end

    test "handles nil values gracefully" do
      params = %{
        "email" => nil,
        "object" => nil,
        "time_slots" => []
      }
      changeset = FreeBusy.changeset(%FreeBusy{}, params)
      assert changeset.valid?
      free_busy = Ecto.Changeset.apply_changes(changeset)
      assert free_busy.email == nil
      assert free_busy.object == nil
      assert free_busy.time_slots == []
    end

    test "creates minimal free/busy with only email" do
      params = %{"email" => "user@example.com"}
      changeset = FreeBusy.changeset(%FreeBusy{}, params)
      assert changeset.valid?
      free_busy = Ecto.Changeset.apply_changes(changeset)
      assert free_busy.email == "user@example.com"
      assert free_busy.time_slots == []
    end
  end
end
