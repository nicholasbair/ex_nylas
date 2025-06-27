defmodule ExNylas.ChannelTest do
  use ExUnit.Case, async: true
  alias ExNylas.Channel

  describe "Channel schema" do
    test "creates a valid channel with all fields" do
      params = %{
        "description" => "Test channel",
        "id" => "chan_123",
        "notification_email_addresses" => ["a@example.com", "b@example.com"],
        "status" => "active",
        "topic" => "messages",
        "trigger_types" => ["message.created", "message.updated"],
        "created_at" => 1_700_000_000,
        "updated_at" => 1_700_000_100,
        "status_updated_at" => 1_700_000_200
      }
      changeset = Channel.changeset(%Channel{}, params)
      assert changeset.valid?
      channel = Ecto.Changeset.apply_changes(changeset)
      assert channel.description == "Test channel"
      assert channel.id == "chan_123"
      assert channel.notification_email_addresses == ["a@example.com", "b@example.com"]
      assert channel.status == :active
      assert channel.topic == "messages"
      assert channel.trigger_types == ["message.created", "message.updated"]
      assert channel.created_at == 1_700_000_000
      assert channel.updated_at == 1_700_000_100
      assert channel.status_updated_at == 1_700_000_200
    end

    test "validates status enum values" do
      valid_statuses = ["active", "pause", "failing", "failed"]
      for status <- valid_statuses do
        params = %{"status" => status}
        changeset = Channel.changeset(%Channel{}, params)
        assert changeset.valid?, "Status #{status} should be valid"
        channel = Ecto.Changeset.apply_changes(changeset)
        assert channel.status == String.to_atom(status)
      end
    end

    test "rejects invalid status values" do
      invalid_statuses = ["inactive", "paused", "error", "unknown"]
      for status <- invalid_statuses do
        params = %{"status" => status}
        changeset = Channel.changeset(%Channel{}, params)
        refute changeset.valid?, "Status #{status} should be invalid"
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "description" => nil,
        "id" => nil,
        "notification_email_addresses" => nil,
        "status" => nil,
        "topic" => nil,
        "trigger_types" => nil,
        "created_at" => nil,
        "updated_at" => nil,
        "status_updated_at" => nil
      }
      changeset = Channel.changeset(%Channel{}, params)
      assert changeset.valid?
      channel = Ecto.Changeset.apply_changes(changeset)
      assert channel.description == nil
      assert channel.id == nil
      assert channel.notification_email_addresses == nil
      assert channel.status == nil
      assert channel.topic == nil
      assert channel.trigger_types == nil
      assert channel.created_at == nil
      assert channel.updated_at == nil
      assert channel.status_updated_at == nil
    end

    test "handles empty arrays for notification_email_addresses and trigger_types" do
      params = %{
        "notification_email_addresses" => [],
        "trigger_types" => []
      }
      changeset = Channel.changeset(%Channel{}, params)
      assert changeset.valid?
      channel = Ecto.Changeset.apply_changes(changeset)
      assert channel.notification_email_addresses == []
      assert channel.trigger_types == []
    end

    test "handles integer timestamps and zero values" do
      params = %{
        "created_at" => 0,
        "updated_at" => 0,
        "status_updated_at" => 0
      }
      changeset = Channel.changeset(%Channel{}, params)
      assert changeset.valid?
      channel = Ecto.Changeset.apply_changes(changeset)
      assert channel.created_at == 0
      assert channel.updated_at == 0
      assert channel.status_updated_at == 0
    end

    test "creates minimal channel with only id and topic" do
      params = %{"id" => "chan_123", "topic" => "messages"}
      changeset = Channel.changeset(%Channel{}, params)
      assert changeset.valid?
      channel = Ecto.Changeset.apply_changes(changeset)
      assert channel.id == "chan_123"
      assert channel.topic == "messages"
    end
  end
end
