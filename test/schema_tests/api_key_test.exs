defmodule ExNylas.APIKeyTest do
  use ExUnit.Case, async: true
  alias ExNylas.APIKey

  describe "APIKey schema" do
    test "creates a valid API key with all fields" do
      params = %{
        "api_key" => "key_123",
        "application_id" => "app_456",
        "created_at" => 1640995200,
        "updated_at" => 1640995300,
        "expires_at" => 1641995200,
        "name" => "Test Key",
        "status" => "active",
        "permissions" => ["read", "write"]
      }

      changeset = APIKey.changeset(%APIKey{}, params)
      assert changeset.valid?
      key = Ecto.Changeset.apply_changes(changeset)
      assert key.api_key == "key_123"
      assert key.application_id == "app_456"
      assert key.created_at == 1640995200
      assert key.updated_at == 1640995300
      assert key.expires_at == 1641995200
      assert key.name == "Test Key"
      assert key.status == :active
      assert key.permissions == ["read", "write"]
    end

    test "validates status enum values" do
      valid_statuses = ["active", "inactive"]
      for status <- valid_statuses do
        params = %{"status" => status}
        changeset = APIKey.changeset(%APIKey{}, params)
        assert changeset.valid?, "Status #{status} should be valid"
      end
    end

    test "rejects invalid status values" do
      invalid_statuses = ["pending", "revoked", "invalid"]
      for status <- invalid_statuses do
        params = %{"status" => status}
        changeset = APIKey.changeset(%APIKey{}, params)
        refute changeset.valid?, "Status #{status} should be invalid"
        assert {:status, _} = List.keyfind(changeset.errors, :status, 0)
      end
    end

    test "handles nil values gracefully" do
      params = %{
        "api_key" => nil,
        "application_id" => nil,
        "created_at" => nil,
        "updated_at" => nil,
        "expires_at" => nil,
        "name" => nil,
        "status" => nil,
        "permissions" => nil
      }
      changeset = APIKey.changeset(%APIKey{}, params)
      assert changeset.valid?
      key = Ecto.Changeset.apply_changes(changeset)
      assert key.api_key == nil
      assert key.application_id == nil
      assert key.created_at == nil
      assert key.updated_at == nil
      assert key.expires_at == nil
      assert key.name == nil
      assert key.status == nil
      assert key.permissions == nil
    end

    test "handles empty arrays" do
      params = %{
        "permissions" => []
      }
      changeset = APIKey.changeset(%APIKey{}, params)
      assert changeset.valid?
      key = Ecto.Changeset.apply_changes(changeset)
      assert key.permissions == []
    end
  end
end
