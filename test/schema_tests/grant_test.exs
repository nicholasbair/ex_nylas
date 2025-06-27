defmodule ExNylas.GrantTest do
  use ExUnit.Case, async: true
  alias ExNylas.Grant

  describe "Grant schema" do
    test "creates a valid grant with all fields" do
      params = %{
        "account_id" => "acc_123",
        "created_at" => 1_700_000_000,
        "email" => "user@example.com",
        "grant_status" => "valid",
        "id" => "grant_123",
        "ip" => "192.168.1.1",
        "provider" => "google",
        "provider_user_id" => "prov_user_456",
        "scope" => ["calendar", "email"],
        "settings" => %{"setting1" => "value1"},
        "state" => "active",
        "updated_at" => 1_700_000_100,
        "user_agent" => "Mozilla/5.0",
        "name" => "Grant Name"
      }
      changeset = Grant.changeset(%Grant{}, params)
      assert changeset.valid?
      grant = Ecto.Changeset.apply_changes(changeset)
      assert grant.account_id == "acc_123"
      assert grant.created_at == 1_700_000_000
      assert grant.email == "user@example.com"
      assert grant.grant_status == :valid
      assert grant.id == "grant_123"
      assert grant.ip == "192.168.1.1"
      assert grant.provider == :google
      assert grant.provider_user_id == "prov_user_456"
      assert grant.scope == ["calendar", "email"]
      assert grant.settings == %{"setting1" => "value1"}
      assert grant.state == "active"
      assert grant.updated_at == 1_700_000_100
      assert grant.user_agent == "Mozilla/5.0"
      assert grant.name == "Grant Name"
    end

    test "validates grant_status enum values" do
      valid_statuses = ["valid", "invalid"]
      for status <- valid_statuses do
        params = %{"grant_status" => status}
        changeset = Grant.changeset(%Grant{}, params)
        assert changeset.valid?, "Status #{status} should be valid"
        grant = Ecto.Changeset.apply_changes(changeset)
        assert grant.grant_status == String.to_atom(status)
      end
    end

    test "rejects invalid grant_status values" do
      invalid_statuses = ["pending", "expired", "unknown"]
      for status <- invalid_statuses do
        params = %{"grant_status" => status}
        changeset = Grant.changeset(%Grant{}, params)
        refute changeset.valid?, "Status #{status} should be invalid"
      end
    end

    test "validates provider enum values" do
      valid_providers = [
        "google", "microsoft", "imap", "virtual-calendar", "icloud", "yahoo", "zoom", "ews"
      ]
      for provider <- valid_providers do
        params = %{"provider" => provider}
        changeset = Grant.changeset(%Grant{}, params)
        assert changeset.valid?, "Provider #{provider} should be valid"
        grant = Ecto.Changeset.apply_changes(changeset)
        assert grant.provider == String.to_atom(provider)
      end
    end

    test "rejects invalid provider values" do
      invalid_providers = ["dropbox", "slack", "invalid"]
      for provider <- invalid_providers do
        params = %{"provider" => provider}
        changeset = Grant.changeset(%Grant{}, params)
        refute changeset.valid?, "Provider #{provider} should be invalid"
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "account_id" => nil,
        "created_at" => nil,
        "email" => nil,
        "grant_status" => nil,
        "id" => nil,
        "ip" => nil,
        "provider" => nil,
        "provider_user_id" => nil,
        "scope" => nil,
        "settings" => nil,
        "state" => nil,
        "updated_at" => nil,
        "user_agent" => nil,
        "name" => nil
      }
      changeset = Grant.changeset(%Grant{}, params)
      assert changeset.valid?
      grant = Ecto.Changeset.apply_changes(changeset)
      assert grant.account_id == nil
      assert grant.created_at == nil
      assert grant.email == nil
      assert grant.grant_status == nil
      assert grant.id == nil
      assert grant.ip == nil
      assert grant.provider == nil
      assert grant.provider_user_id == nil
      assert grant.scope == nil
      assert grant.settings == nil
      assert grant.state == nil
      assert grant.updated_at == nil
      assert grant.user_agent == nil
      assert grant.name == nil
    end

    test "handles empty arrays and maps" do
      params = %{
        "scope" => [],
        "settings" => %{}
      }
      changeset = Grant.changeset(%Grant{}, params)
      assert changeset.valid?
      grant = Ecto.Changeset.apply_changes(changeset)
      assert grant.scope == []
      assert grant.settings == %{}
    end

    test "handles integer timestamps and zero values" do
      params = %{
        "created_at" => 0,
        "updated_at" => 0
      }
      changeset = Grant.changeset(%Grant{}, params)
      assert changeset.valid?
      grant = Ecto.Changeset.apply_changes(changeset)
      assert grant.created_at == 0
      assert grant.updated_at == 0
    end

    test "creates minimal grant with only id and email" do
      params = %{"id" => "grant_123", "email" => "user@example.com"}
      changeset = Grant.changeset(%Grant{}, params)
      assert changeset.valid?
      grant = Ecto.Changeset.apply_changes(changeset)
      assert grant.id == "grant_123"
      assert grant.email == "user@example.com"
    end
  end
end
