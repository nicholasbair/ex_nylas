defmodule ExNylas.MessageTest do
  use ExUnit.Case, async: true
  alias ExNylas.Message

  describe "Message schema" do
    test "creates a valid message with basic fields" do
      params = %{
        "id" => "msg_123",
        "subject" => "Test Subject",
        "body" => "Test body content",
        "grant_id" => "grant_456",
        "thread_id" => "thread_789"
      }

      changeset = Message.changeset(%Message{}, params)
      assert changeset.valid?

      message = Ecto.Changeset.apply_changes(changeset)
      assert message.id == "msg_123"
      assert message.subject == "Test Subject"
      assert message.body == "Test body content"
      assert message.grant_id == "grant_456"
      assert message.thread_id == "thread_789"
    end

    test "handles boolean fields correctly" do
      params = %{
        "starred" => true,
        "unread" => false,
        "snippet" => "Message snippet"
      }

      changeset = Message.changeset(%Message{}, params)
      assert changeset.valid?

      message = Ecto.Changeset.apply_changes(changeset)
      assert message.starred == true
      assert message.unread == false
      assert message.snippet == "Message snippet"
    end

    test "handles integer fields correctly" do
      params = %{
        "date" => 1640995200
      }

      changeset = Message.changeset(%Message{}, params)
      assert changeset.valid?

      message = Ecto.Changeset.apply_changes(changeset)
      assert message.date == 1640995200
    end

    test "handles array fields correctly" do
      params = %{
        "folders" => ["INBOX", "SENT"]
      }

      changeset = Message.changeset(%Message{}, params)
      assert changeset.valid?

      message = Ecto.Changeset.apply_changes(changeset)
      assert message.folders == ["INBOX", "SENT"]
    end

    test "handles metadata map correctly" do
      params = %{
        "metadata" => %{
          "custom_field" => "custom_value",
          "priority" => "high"
        }
      }

      changeset = Message.changeset(%Message{}, params)
      assert changeset.valid?

      message = Ecto.Changeset.apply_changes(changeset)
      assert message.metadata["custom_field"] == "custom_value"
      assert message.metadata["priority"] == "high"
    end
  end

  describe "Message edge cases" do
    test "handles nil values gracefully" do
      params = %{
        "subject" => "Test Subject",
        "body" => nil,
        "starred" => nil,
        "unread" => nil
      }

      changeset = Message.changeset(%Message{}, params)
      assert changeset.valid?

      message = Ecto.Changeset.apply_changes(changeset)
      assert message.subject == "Test Subject"
      assert message.body == nil
      assert message.starred == nil
      assert message.unread == nil
    end

    test "handles empty arrays" do
      params = %{
        "subject" => "Test Subject",
        "folders" => []
      }

      changeset = Message.changeset(%Message{}, params)
      assert changeset.valid?

      message = Ecto.Changeset.apply_changes(changeset)
      assert message.folders == []
    end
  end
end
