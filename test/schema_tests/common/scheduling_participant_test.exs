defmodule ExNylas.SchedulingParticipantTest do
  use ExUnit.Case, async: true
  alias ExNylas.SchedulingParticipant

  describe "SchedulingParticipant schema" do
    test "creates a valid scheduling participant with all fields" do
      params = %{
        "email" => "participant@example.com",
        "is_organizer" => true,
        "name" => "John Doe",
        "availability" => %{
          "calendar_ids" => ["cal_1", "cal_2"]
        },
        "booking" => %{
          "calendar_id" => "cal_1"
        }
      }
      changeset = SchedulingParticipant.changeset(%SchedulingParticipant{}, params)
      assert changeset.valid?
      participant = Ecto.Changeset.apply_changes(changeset)
      assert participant.email == "participant@example.com"
      assert participant.is_organizer == true
      assert participant.name == "John Doe"
      assert participant.availability.calendar_ids == ["cal_1", "cal_2"]
      assert participant.booking.calendar_id == "cal_1"
    end

    test "requires name and email fields" do
      # Missing email
      params = %{"name" => "John Doe"}
      changeset = SchedulingParticipant.changeset(%SchedulingParticipant{}, params)
      refute changeset.valid?
      assert length(changeset.errors) > 0

      # Missing name
      params = %{"email" => "participant@example.com"}
      changeset = SchedulingParticipant.changeset(%SchedulingParticipant{}, params)
      refute changeset.valid?
      assert length(changeset.errors) > 0

      # Both present
      params = %{"name" => "John Doe", "email" => "participant@example.com"}
      changeset = SchedulingParticipant.changeset(%SchedulingParticipant{}, params)
      assert changeset.valid?
    end

    test "handles booleans and nil values for is_organizer" do
      for bool <- [true, false, nil] do
        params = %{
          "name" => "John Doe",
          "email" => "participant@example.com",
          "is_organizer" => bool
        }
        changeset = SchedulingParticipant.changeset(%SchedulingParticipant{}, params)
        assert changeset.valid?
        participant = Ecto.Changeset.apply_changes(changeset)
        assert participant.is_organizer == bool
      end
    end

    test "handles missing embedded associations" do
      params = %{
        "name" => "John Doe",
        "email" => "participant@example.com"
      }
      changeset = SchedulingParticipant.changeset(%SchedulingParticipant{}, params)
      assert changeset.valid?
      participant = Ecto.Changeset.apply_changes(changeset)
      assert participant.availability == nil
      assert participant.booking == nil
    end

    test "handles empty arrays in embedded associations" do
      params = %{
        "name" => "John Doe",
        "email" => "participant@example.com",
        "availability" => %{
          "calendar_ids" => []
        },
        "booking" => %{
          "calendar_id" => "cal_1"
        }
      }
      changeset = SchedulingParticipant.changeset(%SchedulingParticipant{}, params)
      assert changeset.valid?
      participant = Ecto.Changeset.apply_changes(changeset)
      assert participant.availability.calendar_ids == []
      assert participant.booking.calendar_id == "cal_1"
    end

    test "creates minimal scheduling participant with required fields" do
      params = %{"name" => "John Doe", "email" => "participant@example.com"}
      changeset = SchedulingParticipant.changeset(%SchedulingParticipant{}, params)
      assert changeset.valid?
      participant = Ecto.Changeset.apply_changes(changeset)
      assert participant.name == "John Doe"
      assert participant.email == "participant@example.com"
    end
  end
end
