defmodule ExNylas.EventTest do
  use ExUnit.Case, async: true
  alias ExNylas.Event
  alias ExNylas.Event.{Date, Datespan, Timespan}

  describe "Event schema" do
    test "creates a valid event with basic fields" do
      params = %{
        "id" => "event_123",
        "title" => "Test Event",
        "description" => "A test event",
        "location" => "Test Location",
        "grant_id" => "grant_456",
        "calendar_id" => "cal_789"
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.id == "event_123"
      assert event.title == "Test Event"
      assert event.description == "A test event"
      assert event.location == "Test Location"
      assert event.grant_id == "grant_456"
      assert event.calendar_id == "cal_789"
    end

    test "validates status enum values" do
      valid_statuses = ["confirmed", "canceled", "maybe"]

      for status <- valid_statuses do
        params = %{"status" => status}
        changeset = Event.changeset(%Event{}, params)
        assert changeset.valid?, "Status #{status} should be valid"
      end
    end

    test "rejects invalid status values" do
      invalid_statuses = ["pending", "completed", "invalid"]

      for status <- invalid_statuses do
        params = %{"status" => status}
        changeset = Event.changeset(%Event{}, params)

        refute changeset.valid?, "Status #{status} should be invalid"
        # For invalid enum values, the field should be nil
        event = Ecto.Changeset.apply_changes(changeset)
        assert event.status == nil, "Status should be nil for invalid value: #{status}"
      end
    end

    test "validates visibility enum values" do
      valid_visibilities = ["public", "private", "default"]

      for visibility <- valid_visibilities do
        params = %{"visibility" => visibility}
        changeset = Event.changeset(%Event{}, params)
        assert changeset.valid?, "Visibility #{visibility} should be valid"
      end
    end

    test "rejects invalid visibility values" do
      invalid_visibilities = ["secret", "hidden", "invalid"]

      for visibility <- invalid_visibilities do
        params = %{"visibility" => visibility}
        changeset = Event.changeset(%Event{}, params)
        refute changeset.valid?, "Visibility #{visibility} should be invalid"
        # For invalid enum values, Ecto sets the field to nil
        event = Ecto.Changeset.apply_changes(changeset)
        assert event.visibility == nil
      end
    end

    test "handles boolean fields correctly" do
      params = %{
        "busy" => true,
        "hide_participants" => false,
        "read_only" => true
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.busy == true
      assert event.hide_participants == false
      assert event.read_only == true
    end

    test "handles integer fields correctly" do
      params = %{
        "capacity" => 100,
        "created_at" => 1640995200,
        "updated_at" => 1640995200
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.capacity == 100
      assert event.created_at == 1640995200
      assert event.updated_at == 1640995200
    end

    test "handles array fields correctly" do
      params = %{
        "occurrences" => ["2024-01-01", "2024-01-02"],
        "cancelled_occurrences" => ["2024-01-03"],
        "recurrence" => ["FREQ=DAILY", "COUNT=5"]
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.occurrences == ["2024-01-01", "2024-01-02"]
      assert event.cancelled_occurrences == ["2024-01-03"]
      assert event.recurrence == ["FREQ=DAILY", "COUNT=5"]
    end

    test "handles metadata map correctly" do
      params = %{
        "metadata" => %{
          "custom_field" => "custom_value",
          "priority" => "high"
        }
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.metadata["custom_field"] == "custom_value"
      assert event.metadata["priority"] == "high"
    end
  end

  describe "Event participants" do
    test "creates event with participants" do
      params = %{
        "title" => "Team Meeting",
        "participants" => [
          %{
            "email" => "alice@example.com",
            "name" => "Alice Smith",
            "status" => "yes"
          },
          %{
            "email" => "bob@example.com",
            "name" => "Bob Jones",
            "status" => "maybe"
          }
        ]
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert length(event.participants) == 2

      [participant1, participant2] = event.participants
      assert participant1.email == "alice@example.com"
      assert participant1.name == "Alice Smith"
      assert participant1.status == :yes
      assert participant2.email == "bob@example.com"
      assert participant2.name == "Bob Jones"
      assert participant2.status == :maybe
    end

    test "validates participant status enum values" do
      valid_statuses = ["yes", "no", "maybe", "noreply"]

      for status <- valid_statuses do
        params = %{
          "participants" => [
            %{"email" => "test@example.com", "status" => status}
          ]
        }
        changeset = Event.changeset(%Event{}, params)
        assert changeset.valid?, "Participant status #{status} should be valid"
      end
    end

    test "rejects invalid participant status values" do
      invalid_statuses = ["pending", "accepted", "declined"]

      for status <- invalid_statuses do
        params = %{
          "participants" => [
            %{"email" => "test@example.com", "status" => status}
          ]
        }
        changeset = Event.changeset(%Event{}, params)
        refute changeset.valid?, "Participant status #{status} should be invalid"
        # For invalid enum values in embedded schemas, the field is set to nil
        event = Ecto.Changeset.apply_changes(changeset)
        assert length(event.participants) == 1
        assert event.participants |> List.first() |> Map.get(:status) == nil
      end
    end
  end

  describe "Event organizer" do
    test "creates event with organizer" do
      params = %{
        "title" => "Team Meeting",
        "organizer" => %{
          "email" => "organizer@example.com",
          "name" => "Meeting Organizer"
        }
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.organizer.email == "organizer@example.com"
      assert event.organizer.name == "Meeting Organizer"
    end
  end

  describe "Event conferencing" do
    test "creates event with conferencing details" do
      params = %{
        "title" => "Video Meeting",
        "conferencing" => %{
          "provider" => "zoom",
          "details" => %{
            "url" => "https://zoom.us/j/123456789",
            "meeting_code" => "123456789",
            "password" => "secret123",
            "phone" => ["+1-555-123-4567"],
            "pin" => "123456"
          }
        }
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.conferencing.provider == "zoom"
      assert event.conferencing.details.url == "https://zoom.us/j/123456789"
      assert event.conferencing.details.meeting_code == "123456789"
      assert event.conferencing.details.password == "secret123"
      assert event.conferencing.details.phone == ["+1-555-123-4567"]
      assert event.conferencing.details.pin == "123456"
    end
  end

  describe "Event reminders" do
    test "creates event with reminders" do
      params = %{
        "title" => "Important Meeting",
        "reminders" => %{
          "use_default" => false,
          "overrides" => [
            %{"minutes" => 15, "method" => "email"},
            %{"minutes" => 5, "method" => "popup"}
          ]
        }
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.reminders.use_default == false
      assert length(event.reminders.overrides) == 2

      [override1, override2] = event.reminders.overrides
      assert override1["minutes"] == 15
      assert override1["method"] == "email"
      assert override2["minutes"] == 5
      assert override2["method"] == "popup"
    end
  end

  describe "Event polymorphic when field" do
    test "creates event with date when" do
      params = %{
        "title" => "All Day Event",
        "when" => %{
          "object" => "date",
          "date" => "2024-01-01"
        }
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert %Date{} = event.when
      assert event.when.date == "2024-01-01"
    end

    test "creates event with datespan when" do
      params = %{
        "title" => "Multi-day Event",
        "when" => %{
          "object" => "datespan",
          "start_date" => "2024-01-01",
          "end_date" => "2024-01-03"
        }
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert %Datespan{} = event.when
      assert event.when.start_date == "2024-01-01"
      assert event.when.end_date == "2024-01-03"
    end

    test "creates event with timespan when" do
      params = %{
        "title" => "Timed Event",
        "when" => %{
          "object" => "timespan",
          "start_time" => 1640995200,
          "end_time" => 1640998800
        }
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert %Timespan{} = event.when
      assert event.when.start_time == 1640995200
      assert event.when.end_time == 1640998800
    end

    test "rejects invalid when object type" do
      params = %{
        "title" => "Invalid Event",
        "when" => %{
          "object" => "invalid_type",
          "date" => "2024-01-01"
        }
      }

      changeset = Event.changeset(%Event{}, params)
      refute changeset.valid?
    end
  end

  describe "Event edge cases" do
    test "handles empty participants array" do
      params = %{
        "title" => "Empty Event",
        "participants" => []
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.participants == []
    end

    test "handles nil values gracefully" do
      params = %{
        "title" => "Event with Nil Values",
        "description" => nil,
        "location" => nil,
        "capacity" => nil
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.title == "Event with Nil Values"
      assert event.description == nil
      assert event.location == nil
      assert event.capacity == nil
    end

    test "handles empty arrays" do
      params = %{
        "title" => "Event with Empty Arrays",
        "occurrences" => [],
        "cancelled_occurrences" => [],
        "recurrence" => []
      }

      changeset = Event.changeset(%Event{}, params)
      assert changeset.valid?

      event = Ecto.Changeset.apply_changes(changeset)
      assert event.occurrences == []
      assert event.cancelled_occurrences == []
      assert event.recurrence == []
    end
  end
end
