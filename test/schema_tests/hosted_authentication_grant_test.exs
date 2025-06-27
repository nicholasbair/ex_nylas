defmodule ExNylas.HostedAuthentication.GrantTest do
  use ExUnit.Case, async: true
  alias ExNylas.HostedAuthentication.Grant

  describe "HostedAuthentication Grant schema" do
    test "creates a valid hosted authentication grant with all fields" do
      params = %{
        "access_token" => "access_token_123",
        "email" => "user@example.com",
        "expires_in" => 3600,
        "grant_id" => "grant_456",
        "id_token" => "id_token_789",
        "provider" => "google",
        "refresh_token" => "refresh_token_abc",
        "scope" => "calendar email",
        "token_type" => "Bearer"
      }
      changeset = Grant.changeset(%Grant{}, params)
      assert changeset.valid?
      grant = Ecto.Changeset.apply_changes(changeset)
      assert grant.access_token == "access_token_123"
      assert grant.email == "user@example.com"
      assert grant.expires_in == 3600
      assert grant.grant_id == "grant_456"
      assert grant.id_token == "id_token_789"
      assert grant.provider == :google
      assert grant.refresh_token == "refresh_token_abc"
      assert grant.scope == "calendar email"
      assert grant.token_type == "Bearer"
    end

    test "validates provider enum values" do
      valid_providers = [
        "google", "microsoft", "icloud", "yahoo", "imap", "virtual-calendar", "zoom", "ews"
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
        "access_token" => nil,
        "email" => nil,
        "expires_in" => nil,
        "grant_id" => nil,
        "id_token" => nil,
        "provider" => nil,
        "refresh_token" => nil,
        "scope" => nil,
        "token_type" => nil
      }
      changeset = Grant.changeset(%Grant{}, params)
      assert changeset.valid?
      grant = Ecto.Changeset.apply_changes(changeset)
      assert grant.access_token == nil
      assert grant.email == nil
      assert grant.expires_in == nil
      assert grant.grant_id == nil
      assert grant.id_token == nil
      assert grant.provider == nil
      assert grant.refresh_token == nil
      assert grant.scope == nil
      assert grant.token_type == nil
    end

    test "handles non-negative integer timestamps" do
      valid_timestamps = [0, 1, 3600, 86400, 2_147_483_647]
      for timestamp <- valid_timestamps do
        params = %{"expires_in" => timestamp}
        changeset = Grant.changeset(%Grant{}, params)
        assert changeset.valid?, "Timestamp #{timestamp} should be valid"
        grant = Ecto.Changeset.apply_changes(changeset)
        assert grant.expires_in == timestamp
      end
    end

    test "creates minimal hosted authentication grant with only access_token" do
      params = %{"access_token" => "minimal_token"}
      changeset = Grant.changeset(%Grant{}, params)
      assert changeset.valid?
      grant = Ecto.Changeset.apply_changes(changeset)
      assert grant.access_token == "minimal_token"
    end
  end
end
