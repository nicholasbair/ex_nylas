defmodule ExNylas.DraftTest do
  use ExUnit.Case, async: true
  alias ExNylas.Draft

  describe "Draft schema" do
    test "creates a valid draft with all fields" do
      params = %{
        "body" => "Email body content",
        "date" => 1_700_000_000,
        "folders" => ["inbox", "drafts"],
        "grant_id" => "grant_123",
        "id" => "draft_123",
        "object" => "draft",
        "reply_to_message_id" => "msg_456",
        "snippet" => "Email snippet",
        "starred" => false,
        "subject" => "Test Subject",
        "thread_id" => "thread_789",
        "metadata" => %{"key" => "value"},
        "attachments" => [
          %{"id" => "att_1", "filename" => "file1.pdf"},
          %{"id" => "att_2", "filename" => "file2.jpg"}
        ],
        "bcc" => [%{"email" => "bcc@example.com", "name" => "BCC User"}],
        "cc" => [%{"email" => "cc@example.com", "name" => "CC User"}],
        "from" => [%{"email" => "from@example.com", "name" => "From User"}],
        "reply_to" => [%{"email" => "reply@example.com", "name" => "Reply User"}],
        "to" => [%{"email" => "to@example.com", "name" => "To User"}],
        "tracking_options" => %{"links" => true, "opens" => false, "thread_replies" => true}
      }
      changeset = Draft.changeset(%Draft{}, params)
      assert changeset.valid?
      draft = Ecto.Changeset.apply_changes(changeset)
      assert draft.body == "Email body content"
      assert draft.date == 1_700_000_000
      assert draft.folders == ["inbox", "drafts"]
      assert draft.grant_id == "grant_123"
      assert draft.id == "draft_123"
      assert draft.object == "draft"
      assert draft.reply_to_message_id == "msg_456"
      assert draft.snippet == "Email snippet"
      assert draft.starred == false
      assert draft.subject == "Test Subject"
      assert draft.thread_id == "thread_789"
      assert draft.metadata == %{"key" => "value"}
      assert length(draft.attachments) == 2
      assert length(draft.bcc) == 1
      assert length(draft.cc) == 1
      assert length(draft.from) == 1
      assert length(draft.reply_to) == 1
      assert length(draft.to) == 1
      assert draft.tracking_options.links == true
      assert draft.tracking_options.opens == false
      assert draft.tracking_options.thread_replies == true
    end

    test "handles booleans and nil values for boolean fields" do
      for bool <- [true, false, nil] do
        params = %{"starred" => bool}
        changeset = Draft.changeset(%Draft{}, params)
        assert changeset.valid?
        draft = Ecto.Changeset.apply_changes(changeset)
        assert draft.starred == bool
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "body" => nil,
        "date" => nil,
        "folders" => nil,
        "grant_id" => nil,
        "id" => nil,
        "object" => nil,
        "reply_to_message_id" => nil,
        "snippet" => nil,
        "starred" => nil,
        "subject" => nil,
        "thread_id" => nil,
        "metadata" => nil,
        "attachments" => [],
        "bcc" => [],
        "cc" => [],
        "from" => [],
        "reply_to" => [],
        "to" => [],
        "tracking_options" => nil
      }
      changeset = Draft.changeset(%Draft{}, params)
      assert changeset.valid?
      draft = Ecto.Changeset.apply_changes(changeset)
      assert draft.body == nil
      assert draft.date == nil
      assert draft.folders == nil
      assert draft.grant_id == nil
      assert draft.id == nil
      assert draft.object == nil
      assert draft.reply_to_message_id == nil
      assert draft.snippet == nil
      assert draft.starred == nil
      assert draft.subject == nil
      assert draft.thread_id == nil
      assert draft.metadata == nil
      assert draft.attachments == []
      assert draft.bcc == []
      assert draft.cc == []
      assert draft.from == []
      assert draft.reply_to == []
      assert draft.to == []
      assert draft.tracking_options == nil
    end

    test "handles empty arrays for collections" do
      params = %{
        "folders" => [],
        "attachments" => [],
        "bcc" => [],
        "cc" => [],
        "from" => [],
        "reply_to" => [],
        "to" => []
      }
      changeset = Draft.changeset(%Draft{}, params)
      assert changeset.valid?
      draft = Ecto.Changeset.apply_changes(changeset)
      assert draft.folders == []
      assert draft.attachments == []
      assert draft.bcc == []
      assert draft.cc == []
      assert draft.from == []
      assert draft.reply_to == []
      assert draft.to == []
    end

    test "handles empty map for metadata" do
      params = %{"metadata" => %{}}
      changeset = Draft.changeset(%Draft{}, params)
      assert changeset.valid?
      draft = Ecto.Changeset.apply_changes(changeset)
      assert draft.metadata == %{}
    end

    test "creates minimal draft with only id and subject" do
      params = %{"id" => "draft_123", "subject" => "Minimal Draft"}
      changeset = Draft.changeset(%Draft{}, params)
      assert changeset.valid?
      draft = Ecto.Changeset.apply_changes(changeset)
      assert draft.id == "draft_123"
      assert draft.subject == "Minimal Draft"
    end
  end
end
