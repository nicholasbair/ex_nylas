defmodule ExNylas.MessageScheduleTest do
  use ExUnit.Case, async: true
  alias ExNylas.MessageSchedule

  describe "MessageSchedule schema" do
    test "creates a valid message schedule with all fields" do
      params = %{
        "close_time" => 1_700_000_000,
        "schedule_id" => "schedule_123",
        "status" => %{
          "code" => "success",
          "description" => "Message scheduled successfully"
        }
      }
      changeset = MessageSchedule.changeset(%MessageSchedule{}, params)
      assert changeset.valid?
      schedule = Ecto.Changeset.apply_changes(changeset)
      assert schedule.close_time == 1_700_000_000
      assert schedule.schedule_id == "schedule_123"
      assert schedule.status.code == "success"
      assert schedule.status.description == "Message scheduled successfully"
    end

    test "handles nil close_time" do
      params = %{
        "schedule_id" => "schedule_123",
        "close_time" => nil
      }
      changeset = MessageSchedule.changeset(%MessageSchedule{}, params)
      assert changeset.valid?
      schedule = Ecto.Changeset.apply_changes(changeset)
      assert schedule.close_time == nil
      assert schedule.schedule_id == "schedule_123"
    end

    test "handles non-negative integer timestamps" do
      valid_timestamps = [0, 1, 1640995200, 2_147_483_647]
      for timestamp <- valid_timestamps do
        params = %{
          "schedule_id" => "schedule_123",
          "close_time" => timestamp
        }
        changeset = MessageSchedule.changeset(%MessageSchedule{}, params)
        assert changeset.valid?, "Timestamp #{timestamp} should be valid"
        schedule = Ecto.Changeset.apply_changes(changeset)
        assert schedule.close_time == timestamp
      end
    end

    test "handles missing status" do
      params = %{
        "schedule_id" => "schedule_123"
      }
      changeset = MessageSchedule.changeset(%MessageSchedule{}, params)
      assert changeset.valid?
      schedule = Ecto.Changeset.apply_changes(changeset)
      assert schedule.schedule_id == "schedule_123"
      assert schedule.status == nil
    end

    test "handles nil values for all fields" do
      params = %{
        "close_time" => nil,
        "schedule_id" => nil,
        "status" => nil
      }
      changeset = MessageSchedule.changeset(%MessageSchedule{}, params)
      assert changeset.valid?
      schedule = Ecto.Changeset.apply_changes(changeset)
      assert schedule.close_time == nil
      assert schedule.schedule_id == nil
      assert schedule.status == nil
    end

    test "creates minimal message schedule with only schedule_id" do
      params = %{"schedule_id" => "schedule_123"}
      changeset = MessageSchedule.changeset(%MessageSchedule{}, params)
      assert changeset.valid?
      schedule = Ecto.Changeset.apply_changes(changeset)
      assert schedule.schedule_id == "schedule_123"
    end
  end
end
