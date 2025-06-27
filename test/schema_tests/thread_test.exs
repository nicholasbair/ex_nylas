defmodule ExNylas.ThreadTest do
  use ExUnit.Case, async: true
  alias ExNylas.Thread

  describe "Thread schema" do
    test "creates a valid thread with all fields" do
      params = %{
        "draft_ids" => ["draft_1", "draft_2"],
        "earliest_message_date" => 1_700_000_000,
        "grant_id" => "grant_123",
        "has_attachments" => true,
        "has_drafts" => false,
        "id" => "thread_123",
        "latest_message_received_date" => 1_700_000_100,
        "latest_message_sent_date" => 1_700_000_200,
        "message_ids" => ["msg_1", "msg_2", "msg_3"],
        "object" => "thread",
        "snippet" => "Latest message snippet",
        "starred" => false,
        "subject" => "Test Thread Subject",
        "unread" => true,
        "participants" => [
          %{"email" => "user1@example.com", "name" => "User 1"},
          %{"email" => "user2@example.com", "name" => "User 2"}
        ]
      }
      changeset = Thread.changeset(%Thread{}, params)
      assert changeset.valid?
      thread = Ecto.Changeset.apply_changes(changeset)
      assert thread.draft_ids == ["draft_1", "draft_2"]
      assert thread.earliest_message_date == 1_700_000_000
      assert thread.grant_id == "grant_123"
      assert thread.has_attachments == true
      assert thread.has_drafts == false
      assert thread.id == "thread_123"
      assert thread.latest_message_received_date == 1_700_000_100
      assert thread.latest_message_sent_date == 1_700_000_200
      assert thread.message_ids == ["msg_1", "msg_2", "msg_3"]
      assert thread.object == "thread"
      assert thread.snippet == "Latest message snippet"
      assert thread.starred == false
      assert thread.subject == "Test Thread Subject"
      assert thread.unread == true
      assert length(thread.participants) == 2
    end

    test "handles booleans and nil values for boolean fields" do
      for bool <- [true, false, nil] do
        params = %{
          "has_attachments" => bool,
          "has_drafts" => bool,
          "starred" => bool,
          "unread" => bool
        }
        changeset = Thread.changeset(%Thread{}, params)
        assert changeset.valid?
        thread = Ecto.Changeset.apply_changes(changeset)
        assert thread.has_attachments == bool
        assert thread.has_drafts == bool
        assert thread.starred == bool
        assert thread.unread == bool
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "draft_ids" => [],
        "earliest_message_date" => nil,
        "grant_id" => nil,
        "has_attachments" => nil,
        "has_drafts" => nil,
        "id" => nil,
        "latest_message_received_date" => nil,
        "latest_message_sent_date" => nil,
        "message_ids" => [],
        "object" => nil,
        "snippet" => nil,
        "starred" => nil,
        "subject" => nil,
        "unread" => nil,
        "participants" => []
      }
      changeset = Thread.changeset(%Thread{}, params)
      if not changeset.valid? do
        IO.inspect(changeset.errors, label: "Changeset errors")
      end
      assert changeset.valid?
      thread = Ecto.Changeset.apply_changes(changeset)
      assert thread.draft_ids == []
      assert thread.earliest_message_date == nil
      assert thread.grant_id == nil
      assert thread.has_attachments == nil
      assert thread.has_drafts == nil
      assert thread.id == nil
      assert thread.latest_message_received_date == nil
      assert thread.latest_message_sent_date == nil
      assert thread.message_ids == []
      assert thread.object == nil
      assert thread.snippet == nil
      assert thread.starred == nil
      assert thread.subject == nil
      assert thread.unread == nil
      assert thread.participants == []
    end

    test "handles empty arrays" do
      params = %{
        "draft_ids" => [],
        "message_ids" => [],
        "participants" => []
      }
      changeset = Thread.changeset(%Thread{}, params)
      assert changeset.valid?
      thread = Ecto.Changeset.apply_changes(changeset)
      assert thread.draft_ids == []
      assert thread.message_ids == []
      assert thread.participants == []
    end

    test "handles integer timestamps and zero values" do
      params = %{
        "earliest_message_date" => 0,
        "latest_message_received_date" => 0,
        "latest_message_sent_date" => 0
      }
      changeset = Thread.changeset(%Thread{}, params)
      assert changeset.valid?
      thread = Ecto.Changeset.apply_changes(changeset)
      assert thread.earliest_message_date == 0
      assert thread.latest_message_received_date == 0
      assert thread.latest_message_sent_date == 0
    end

    test "creates minimal thread with only id and subject" do
      params = %{"id" => "thread_123", "subject" => "Minimal Thread"}
      changeset = Thread.changeset(%Thread{}, params)
      assert changeset.valid?
      thread = Ecto.Changeset.apply_changes(changeset)
      assert thread.id == "thread_123"
      assert thread.subject == "Minimal Thread"
    end
  end
end
