defmodule ExNylas.EventConferencingTest do
  use ExUnit.Case, async: true
  alias ExNylas.EventConferencing

  describe "EventConferencing schema" do
    test "creates a valid event conferencing with all fields" do
      params = %{
        "autocreate" => %{"provider" => "google_meet"},
        "provider" => "Google Meet",
        "details" => %{
          "meeting_code" => "abc-123-def",
          "password" => "secret123",
          "phone" => ["+1-555-123-4567", "+1-555-987-6543"],
          "pin" => "123456",
          "url" => "https://meet.google.com/abc-123-def"
        }
      }
      changeset = EventConferencing.changeset(%EventConferencing{}, params)
      assert changeset.valid?
      conferencing = Ecto.Changeset.apply_changes(changeset)
      assert conferencing.autocreate == %{"provider" => "google_meet"}
      assert conferencing.provider == :"Google Meet"
      assert conferencing.details.meeting_code == "abc-123-def"
      assert conferencing.details.password == "secret123"
      assert conferencing.details.phone == ["+1-555-123-4567", "+1-555-987-6543"]
      assert conferencing.details.pin == "123456"
      assert conferencing.details.url == "https://meet.google.com/abc-123-def"
    end

    test "handles all valid provider enum values" do
      valid_providers = [
        "Google Meet",
        "Zoom Meeting",
        "Microsoft Teams",
        "Teams for Business",
        "Skype for Consumer",
        "Skype for Business"
      ]

      for provider <- valid_providers do
        params = %{"provider" => provider}
        changeset = EventConferencing.changeset(%EventConferencing{}, params)
        assert changeset.valid?, "Provider #{provider} should be valid"
        conferencing = Ecto.Changeset.apply_changes(changeset)
        assert conferencing.provider == String.to_atom(provider)
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "autocreate" => nil,
        "provider" => "Google Meet",
        "details" => nil
      }
      changeset = EventConferencing.changeset(%EventConferencing{}, params)
      assert changeset.valid?
      conferencing = Ecto.Changeset.apply_changes(changeset)
      assert conferencing.autocreate == nil
      assert conferencing.provider == :"Google Meet"
      assert conferencing.details == nil
    end

    test "handles empty autocreate map" do
      params = %{
        "autocreate" => %{},
        "provider" => "Zoom Meeting"
      }
      changeset = EventConferencing.changeset(%EventConferencing{}, params)
      assert changeset.valid?
      conferencing = Ecto.Changeset.apply_changes(changeset)
      assert conferencing.autocreate == %{}
    end

    test "handles details with partial fields" do
      params = %{
        "provider" => "Microsoft Teams",
        "details" => %{
          "url" => "https://teams.microsoft.com/meeting",
          "meeting_code" => "teams-123"
        }
      }
      changeset = EventConferencing.changeset(%EventConferencing{}, params)
      assert changeset.valid?
      conferencing = Ecto.Changeset.apply_changes(changeset)
      assert conferencing.details.url == "https://teams.microsoft.com/meeting"
      assert conferencing.details.meeting_code == "teams-123"
      assert conferencing.details.password == nil
      assert conferencing.details.phone == nil
      assert conferencing.details.pin == nil
    end

    test "handles empty phone array" do
      params = %{
        "provider" => "Skype for Business",
        "details" => %{
          "phone" => []
        }
      }
      changeset = EventConferencing.changeset(%EventConferencing{}, params)
      assert changeset.valid?
      conferencing = Ecto.Changeset.apply_changes(changeset)
      assert conferencing.details.phone == []
    end

    test "creates minimal conferencing with only provider" do
      params = %{"provider" => "Teams for Business"}
      changeset = EventConferencing.changeset(%EventConferencing{}, params)
      assert changeset.valid?
      conferencing = Ecto.Changeset.apply_changes(changeset)
      assert conferencing.provider == :"Teams for Business"
      assert conferencing.autocreate == nil
      assert conferencing.details == nil
    end
  end
end
