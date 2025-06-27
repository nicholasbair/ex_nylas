defmodule ExNylas.EmailParticipantTest do
  use ExUnit.Case, async: true
  alias ExNylas.EmailParticipant

  describe "EmailParticipant schema" do
    test "creates a valid email participant with all fields" do
      params = %{
        "email" => "user@example.com",
        "name" => "John Doe"
      }
      changeset = EmailParticipant.changeset(%EmailParticipant{}, params)
      assert changeset.valid?
      participant = Ecto.Changeset.apply_changes(changeset)
      assert participant.email == "user@example.com"
      assert participant.name == "John Doe"
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "email" => nil,
        "name" => nil
      }
      changeset = EmailParticipant.changeset(%EmailParticipant{}, params)
      assert changeset.valid?
      participant = Ecto.Changeset.apply_changes(changeset)
      assert participant.email == nil
      assert participant.name == nil
    end

    test "creates minimal email participant with only email" do
      params = %{"email" => "user@example.com"}
      changeset = EmailParticipant.changeset(%EmailParticipant{}, params)
      assert changeset.valid?
      participant = Ecto.Changeset.apply_changes(changeset)
      assert participant.email == "user@example.com"
      assert participant.name == nil
    end

    test "creates minimal email participant with empty params" do
      params = %{}
      changeset = EmailParticipant.changeset(%EmailParticipant{}, params)
      assert changeset.valid?
      participant = Ecto.Changeset.apply_changes(changeset)
      assert participant.email == nil
      assert participant.name == nil
    end
  end
end
