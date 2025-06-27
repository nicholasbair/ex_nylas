defmodule ExNylas.WebhookTest do
  use ExUnit.Case, async: true
  alias ExNylas.Webhook

  describe "Webhook schema" do
    test "creates a valid webhook with all fields" do
      params = %{
        "description" => "Test webhook",
        "id" => "webhook_123",
        "notification_email_addresses" => ["admin@example.com", "dev@example.com"],
        "status" => "active",
        "trigger_types" => ["message.created", "message.updated"],
        "webhook_url" => "https://example.com/webhook",
        "webhook_secret" => "secret_key_123"
      }
      changeset = Webhook.changeset(%Webhook{}, params)
      assert changeset.valid?
      webhook = Ecto.Changeset.apply_changes(changeset)
      assert webhook.description == "Test webhook"
      assert webhook.id == "webhook_123"
      assert webhook.notification_email_addresses == ["admin@example.com", "dev@example.com"]
      assert webhook.status == :active
      assert webhook.trigger_types == ["message.created", "message.updated"]
      assert webhook.webhook_url == "https://example.com/webhook"
      assert webhook.webhook_secret == "secret_key_123"
    end

    test "validates status enum values" do
      valid_statuses = ["active", "pause", "failing", "failed"]
      for status <- valid_statuses do
        params = %{"status" => status}
        changeset = Webhook.changeset(%Webhook{}, params)
        assert changeset.valid?, "Status #{status} should be valid"
        webhook = Ecto.Changeset.apply_changes(changeset)
        assert webhook.status == String.to_atom(status)
      end
    end

    test "rejects invalid status values" do
      invalid_statuses = ["inactive", "paused", "error", "unknown"]
      for status <- invalid_statuses do
        params = %{"status" => status}
        changeset = Webhook.changeset(%Webhook{}, params)
        refute changeset.valid?, "Status #{status} should be invalid"
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "description" => nil,
        "id" => nil,
        "notification_email_addresses" => nil,
        "status" => nil,
        "trigger_types" => nil,
        "webhook_url" => nil,
        "webhook_secret" => nil
      }
      changeset = Webhook.changeset(%Webhook{}, params)
      assert changeset.valid?
      webhook = Ecto.Changeset.apply_changes(changeset)
      assert webhook.description == nil
      assert webhook.id == nil
      assert webhook.notification_email_addresses == nil
      assert webhook.status == nil
      assert webhook.trigger_types == nil
      assert webhook.webhook_url == nil
      assert webhook.webhook_secret == nil
    end

    test "handles empty arrays for notification_email_addresses and trigger_types" do
      params = %{
        "notification_email_addresses" => [],
        "trigger_types" => []
      }
      changeset = Webhook.changeset(%Webhook{}, params)
      assert changeset.valid?
      webhook = Ecto.Changeset.apply_changes(changeset)
      assert webhook.notification_email_addresses == []
      assert webhook.trigger_types == []
    end

    test "creates minimal webhook with only id and webhook_url" do
      params = %{"id" => "webhook_123", "webhook_url" => "https://example.com/webhook"}
      changeset = Webhook.changeset(%Webhook{}, params)
      assert changeset.valid?
      webhook = Ecto.Changeset.apply_changes(changeset)
      assert webhook.id == "webhook_123"
      assert webhook.webhook_url == "https://example.com/webhook"
    end
  end
end
