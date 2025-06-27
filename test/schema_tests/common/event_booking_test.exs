defmodule ExNylas.EventBookingTest do
  use ExUnit.Case, async: true
  alias ExNylas.EventBooking

  describe "EventBooking schema" do
    test "creates a valid event booking with all fields" do
      params = %{
        "additional_fields" => %{"custom_field" => "value"},
        "booking_type" => "booking",
        "description" => "Team meeting to discuss project progress",
        "disable_emails" => false,
        "hide_participants" => true,
        "location" => "Conference Room A",
        "title" => "Weekly Team Meeting",
        "timezone" => "America/New_York",
        "conferencing" => %{
          "provider" => "Google Meet",
          "details" => %{
            "url" => "https://meet.google.com/abc-123-def"
          }
        },
        "reminders" => %{
          "overrides" => [%{"minutes_before_event" => 15, "type" => "email"}],
          "use_default" => false
        }
      }
      changeset = EventBooking.changeset(%EventBooking{}, params)
      assert changeset.valid?
      booking = Ecto.Changeset.apply_changes(changeset)
      assert booking.additional_fields == %{"custom_field" => "value"}
      assert booking.booking_type == :booking
      assert booking.description == "Team meeting to discuss project progress"
      assert booking.disable_emails == false
      assert booking.hide_participants == true
      assert booking.location == "Conference Room A"
      assert booking.title == "Weekly Team Meeting"
      assert booking.timezone == "America/New_York"
      assert booking.conferencing.provider == :"Google Meet"
      assert booking.conferencing.details.url == "https://meet.google.com/abc-123-def"
      assert booking.reminders != nil
      assert booking.reminders.overrides == [%{"minutes_before_event" => 15, "type" => "email"}]
      assert booking.reminders.use_default == false
    end

    test "handles all valid booking_type enum values" do
      valid_types = ["booking", "organizer-confirmation", "custom-confirmation"]

      for booking_type <- valid_types do
        params = %{"booking_type" => booking_type}
        changeset = EventBooking.changeset(%EventBooking{}, params)
        assert changeset.valid?, "Booking type #{booking_type} should be valid"
        booking = Ecto.Changeset.apply_changes(changeset)
        assert booking.booking_type == String.to_atom(booking_type)
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "additional_fields" => nil,
        "booking_type" => "booking",
        "description" => nil,
        "disable_emails" => nil,
        "hide_participants" => nil,
        "location" => nil,
        "title" => nil,
        "timezone" => nil,
        "conferencing" => nil,
        "reminders" => nil
      }
      changeset = EventBooking.changeset(%EventBooking{}, params)
      assert changeset.valid?
      booking = Ecto.Changeset.apply_changes(changeset)
      assert booking.additional_fields == nil
      assert booking.booking_type == :booking
      assert booking.description == nil
      assert booking.disable_emails == nil
      assert booking.hide_participants == nil
      assert booking.location == nil
      assert booking.title == nil
      assert booking.timezone == nil
      assert booking.conferencing == nil
      assert booking.reminders == nil
    end

    test "handles empty additional_fields map" do
      params = %{
        "additional_fields" => %{},
        "booking_type" => "organizer-confirmation"
      }
      changeset = EventBooking.changeset(%EventBooking{}, params)
      assert changeset.valid?
      booking = Ecto.Changeset.apply_changes(changeset)
      assert booking.additional_fields == %{}
    end

    test "handles boolean fields correctly" do
      params = %{
        "booking_type" => "custom-confirmation",
        "disable_emails" => true,
        "hide_participants" => false
      }
      changeset = EventBooking.changeset(%EventBooking{}, params)
      assert changeset.valid?
      booking = Ecto.Changeset.apply_changes(changeset)
      assert booking.disable_emails == true
      assert booking.hide_participants == false
    end

    test "handles partial conferencing data" do
      params = %{
        "booking_type" => "booking",
        "conferencing" => %{
          "provider" => "Zoom Meeting"
        }
      }
      changeset = EventBooking.changeset(%EventBooking{}, params)
      assert changeset.valid?
      booking = Ecto.Changeset.apply_changes(changeset)
      assert booking.conferencing.provider == :"Zoom Meeting"
      assert booking.conferencing.details == nil
    end

    test "handles partial reminders data" do
      params = %{
        "booking_type" => "booking",
        "reminders" => %{
          "use_default" => true
        }
      }
      changeset = EventBooking.changeset(%EventBooking{}, params)
      assert changeset.valid?
      booking = Ecto.Changeset.apply_changes(changeset)
      assert booking.reminders != nil
      assert booking.reminders.use_default == true
      assert booking.reminders.overrides == nil
    end

    test "creates minimal booking with only booking_type" do
      params = %{"booking_type" => "booking"}
      changeset = EventBooking.changeset(%EventBooking{}, params)
      assert changeset.valid?
      booking = Ecto.Changeset.apply_changes(changeset)
      assert booking.booking_type == :booking
      assert booking.title == nil
      assert booking.location == nil
      assert booking.description == nil
    end

    test "handles special characters in text fields" do
      params = %{
        "booking_type" => "booking",
        "title" => "Meeting with @#$% symbols & spaces",
        "description" => "Description with\nnewlines\tand\ttabs",
        "location" => "Room 123-A (Building B)"
      }
      changeset = EventBooking.changeset(%EventBooking{}, params)
      assert changeset.valid?
      booking = Ecto.Changeset.apply_changes(changeset)
      assert booking.title == "Meeting with @#$% symbols & spaces"
      assert booking.description == "Description with\nnewlines\tand\ttabs"
      assert booking.location == "Room 123-A (Building B)"
    end
  end
end
