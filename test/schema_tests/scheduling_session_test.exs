defmodule ExNylas.Scheduling.SessionTest do
  use ExUnit.Case, async: true
  alias ExNylas.Scheduling.Session

  describe "Scheduling Session schema" do
    test "creates a valid scheduling session with session_id" do
      params = %{
        "session_id" => "session_123"
      }
      changeset = Session.changeset(%Session{}, params)
      assert changeset.valid?
      session = Ecto.Changeset.apply_changes(changeset)
      assert session.session_id == "session_123"
    end

    test "handles nil session_id" do
      params = %{"session_id" => nil}
      changeset = Session.changeset(%Session{}, params)
      assert changeset.valid?
      session = Ecto.Changeset.apply_changes(changeset)
      assert session.session_id == nil
    end

    test "creates minimal scheduling session with empty params" do
      params = %{}
      changeset = Session.changeset(%Session{}, params)
      assert changeset.valid?
      session = Ecto.Changeset.apply_changes(changeset)
      assert session.session_id == nil
    end
  end
end
