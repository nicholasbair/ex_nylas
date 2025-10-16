defmodule ExNylas.NotetakerTest do
  use ExUnit.Case, async: true
  alias ExNylas.Notetaker

  describe "Notetaker schema" do
    test "creates a valid notetaker with all fields" do
      params = %{
        "id" => "nt_123",
        "created_at" => 1_700_000_000,
        "grant_id" => "grant_456",
        "name" => "Meeting Notes",
        "join_time" => 1_700_000_100,
        "meeting_link" => "https://meet.google.com/abc-defg-hij",
        "meeting_provider" => "Google Meet",
        "state" => "scheduled",
        "meeting_settings" => %{
          "video_recording" => true,
          "audio_recording" => false,
          "transcription" => true,
          "action_items" => true,
          "action_items_settings" => %{
            "custom_instructions" => "Foo bar"
          },
          "summary" => true,
          "summary_settings" => %{
            "custom_instructions" => "Foo bar"
          },
        },
        "rules" => %{
          "event_selection" => "internal",
          "participant_filter" => %{
            "participants_gte" => 2,
            "participants_lte" => 10
          }
        }
      }
      changeset = Notetaker.changeset(%Notetaker{}, params)
      assert changeset.valid?
      notetaker = Ecto.Changeset.apply_changes(changeset)
      assert notetaker.id == "nt_123"
      assert notetaker.created_at == 1_700_000_000
      assert notetaker.grant_id == "grant_456"
      assert notetaker.name == "Meeting Notes"
      assert notetaker.join_time == 1_700_000_100
      assert notetaker.meeting_link == "https://meet.google.com/abc-defg-hij"
      assert notetaker.meeting_provider == :"Google Meet"
      assert notetaker.state == :scheduled
      assert notetaker.meeting_settings.video_recording == true
      assert notetaker.meeting_settings.audio_recording == false
      assert notetaker.meeting_settings.transcription == true
      assert notetaker.rules.event_selection == :internal
      assert notetaker.rules.participant_filter.participants_gte == 2
      assert notetaker.rules.participant_filter.participants_lte == 10
    end

    test "validates meeting_provider enum values" do
      valid_providers = ["Google Meet", "Zoom Meeting", "Microsoft Teams"]
      for provider <- valid_providers do
        params = %{"meeting_provider" => provider}
        changeset = Notetaker.changeset(%Notetaker{}, params)
        assert changeset.valid?, "Provider #{provider} should be valid"
        notetaker = Ecto.Changeset.apply_changes(changeset)
        assert notetaker.meeting_provider == String.to_atom(provider)
      end
    end

    test "rejects invalid meeting_provider values" do
      invalid_providers = ["Skype", "Webex", "invalid"]
      for provider <- invalid_providers do
        params = %{"meeting_provider" => provider}
        changeset = Notetaker.changeset(%Notetaker{}, params)
        refute changeset.valid?, "Provider #{provider} should be invalid"
      end
    end

    test "validates state enum values" do
      valid_states = [
        "scheduled", "connecting", "waiting_for_entry", "failed_entry",
        "attending", "media_processing", "media_available", "media_error", "media_deleted"
      ]
      for state <- valid_states do
        params = %{"state" => state}
        changeset = Notetaker.changeset(%Notetaker{}, params)
        assert changeset.valid?, "State #{state} should be valid"
        notetaker = Ecto.Changeset.apply_changes(changeset)
        assert notetaker.state == String.to_atom(state)
      end
    end

    test "rejects invalid state values" do
      invalid_states = ["pending", "completed", "cancelled", "invalid"]
      for state <- invalid_states do
        params = %{"state" => state}
        changeset = Notetaker.changeset(%Notetaker{}, params)
        refute changeset.valid?, "State #{state} should be invalid"
      end
    end

    test "validates event_selection enum values" do
      valid_selections = ["internal", "external", "own_events", "participant_only", "all"]
      for selection <- valid_selections do
        params = %{"rules" => %{"event_selection" => selection}}
        changeset = Notetaker.changeset(%Notetaker{}, params)
        assert changeset.valid?, "Selection #{selection} should be valid"
        notetaker = Ecto.Changeset.apply_changes(changeset)
        assert notetaker.rules.event_selection == String.to_atom(selection)
      end
    end

    test "rejects invalid event_selection values" do
      invalid_selections = ["custom", "default", "invalid"]
      for selection <- invalid_selections do
        params = %{"rules" => %{"event_selection" => selection}}
        changeset = Notetaker.changeset(%Notetaker{}, params)
        refute changeset.valid?, "Selection #{selection} should be invalid"
      end
    end

    test "handles booleans and nil values for boolean fields" do
      for bool <- [true, false, nil] do
        params = %{
          "meeting_settings" => %{
            "video_recording" => bool,
            "audio_recording" => bool,
            "transcription" => bool
          }
        }
        changeset = Notetaker.changeset(%Notetaker{}, params)
        assert changeset.valid?
        notetaker = Ecto.Changeset.apply_changes(changeset)
        assert notetaker.meeting_settings.video_recording == bool
        assert notetaker.meeting_settings.audio_recording == bool
        assert notetaker.meeting_settings.transcription == bool
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "id" => nil,
        "created_at" => nil,
        "grant_id" => nil,
        "name" => nil,
        "join_time" => nil,
        "meeting_link" => nil,
        "meeting_provider" => nil,
        "state" => nil,
        "meeting_settings" => nil,
        "rules" => nil
      }
      changeset = Notetaker.changeset(%Notetaker{}, params)
      assert changeset.valid?
      notetaker = Ecto.Changeset.apply_changes(changeset)
      assert notetaker.id == nil
      assert notetaker.created_at == nil
      assert notetaker.grant_id == nil
      assert notetaker.name == nil
      assert notetaker.join_time == nil
      assert notetaker.meeting_link == nil
      assert notetaker.meeting_provider == nil
      assert notetaker.state == nil
      assert notetaker.meeting_settings == nil
      assert notetaker.rules == nil
    end

    test "handles integer timestamps and zero values" do
      params = %{
        "created_at" => 0,
        "join_time" => 0
      }
      changeset = Notetaker.changeset(%Notetaker{}, params)
      assert changeset.valid?
      notetaker = Ecto.Changeset.apply_changes(changeset)
      assert notetaker.created_at == 0
      assert notetaker.join_time == 0
    end

    test "handles participant filter with integer values" do
      params = %{
        "rules" => %{
          "participant_filter" => %{
            "participants_gte" => 0,
            "participants_lte" => 100
          }
        }
      }
      changeset = Notetaker.changeset(%Notetaker{}, params)
      assert changeset.valid?
      notetaker = Ecto.Changeset.apply_changes(changeset)
      assert notetaker.rules.participant_filter.participants_gte == 0
      assert notetaker.rules.participant_filter.participants_lte == 100
    end

    test "creates minimal notetaker with only id and name" do
      params = %{"id" => "nt_123", "name" => "Minimal Notetaker"}
      changeset = Notetaker.changeset(%Notetaker{}, params)
      assert changeset.valid?
      notetaker = Ecto.Changeset.apply_changes(changeset)
      assert notetaker.id == "nt_123"
      assert notetaker.name == "Minimal Notetaker"
    end
  end
end
