defmodule ExNylas.ConnectorTest do
  use ExUnit.Case, async: true
  alias ExNylas.Connector

  describe "Connector schema" do
    test "creates a valid connector with all fields" do
      params = %{
        "provider" => "google",
        "scope" => ["calendar", "email"],
        "settings" => %{
          "client_id" => "client_123",
          "project_id" => "proj_456",
          "tenant" => "tenant_789",
          "topic_name" => "topic_abc"
        }
      }
      changeset = Connector.changeset(%Connector{}, params)
      assert changeset.valid?
      connector = Ecto.Changeset.apply_changes(changeset)
      assert connector.provider == :google
      assert connector.scope == ["calendar", "email"]
      assert connector.settings.client_id == "client_123"
      assert connector.settings.project_id == "proj_456"
      assert connector.settings.tenant == "tenant_789"
      assert connector.settings.topic_name == "topic_abc"
    end

    test "validates provider enum values" do
      valid_providers = [
        "google", "microsoft", "imap", "virtual-calendar", "icloud", "yahoo", "zoom", "ews"
      ]
      for provider <- valid_providers do
        params = %{"provider" => provider}
        changeset = Connector.changeset(%Connector{}, params)
        assert changeset.valid?, "Provider #{provider} should be valid"
        connector = Ecto.Changeset.apply_changes(changeset)
        assert connector.provider == String.to_atom(provider)
      end
    end

    test "rejects invalid provider values" do
      invalid_providers = ["dropbox", "slack", "invalid"]
      for provider <- invalid_providers do
        params = %{"provider" => provider}
        changeset = Connector.changeset(%Connector{}, params)
        refute changeset.valid?, "Provider #{provider} should be invalid"
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "provider" => nil,
        "scope" => nil,
        "settings" => nil
      }
      changeset = Connector.changeset(%Connector{}, params)
      assert changeset.valid?
      connector = Ecto.Changeset.apply_changes(changeset)
      assert connector.provider == nil
      assert connector.scope == nil
      assert connector.settings == nil
    end

    test "handles empty array for scope" do
      params = %{"scope" => []}
      changeset = Connector.changeset(%Connector{}, params)
      assert changeset.valid?
      connector = Ecto.Changeset.apply_changes(changeset)
      assert connector.scope == []
    end

    test "handles missing settings" do
      params = %{"provider" => "google"}
      changeset = Connector.changeset(%Connector{}, params)
      assert changeset.valid?
      connector = Ecto.Changeset.apply_changes(changeset)
      assert connector.provider == :google
      assert connector.settings == nil
    end

    test "creates minimal connector with only provider" do
      params = %{"provider" => "google"}
      changeset = Connector.changeset(%Connector{}, params)
      assert changeset.valid?
      connector = Ecto.Changeset.apply_changes(changeset)
      assert connector.provider == :google
    end
  end
end
