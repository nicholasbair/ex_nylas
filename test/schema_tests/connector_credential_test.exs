defmodule ExNylas.ConnectorCredentialTest do
  use ExUnit.Case, async: true
  alias ExNylas.ConnectorCredential

  describe "ConnectorCredential schema" do
    test "creates a valid connector credential with all fields" do
      params = %{
        "created_at" => 1_700_000_000,
        "credential_type" => "adminconsent",
        "hashed_data" => "hashed_value",
        "id" => "cred_123",
        "name" => "Credential Name",
        "updated_at" => 1_700_000_100
      }
      changeset = ConnectorCredential.changeset(%ConnectorCredential{}, params)
      assert changeset.valid?
      cred = Ecto.Changeset.apply_changes(changeset)
      assert cred.created_at == 1_700_000_000
      assert cred.credential_type == :adminconsent
      assert cred.hashed_data == "hashed_value"
      assert cred.id == "cred_123"
      assert cred.name == "Credential Name"
      assert cred.updated_at == 1_700_000_100
    end

    test "validates credential_type enum values" do
      valid_types = ["adminconsent", "serviceaccount"]
      for type <- valid_types do
        params = %{"credential_type" => type}
        changeset = ConnectorCredential.changeset(%ConnectorCredential{}, params)
        assert changeset.valid?, "Type #{type} should be valid"
        cred = Ecto.Changeset.apply_changes(changeset)
        assert cred.credential_type == String.to_atom(type)
      end
    end

    test "rejects invalid credential_type values" do
      invalid_types = ["userconsent", "apikey", "invalid"]
      for type <- invalid_types do
        params = %{"credential_type" => type}
        changeset = ConnectorCredential.changeset(%ConnectorCredential{}, params)
        refute changeset.valid?, "Type #{type} should be invalid"
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "created_at" => nil,
        "credential_type" => nil,
        "hashed_data" => nil,
        "id" => nil,
        "name" => nil,
        "updated_at" => nil
      }
      changeset = ConnectorCredential.changeset(%ConnectorCredential{}, params)
      assert changeset.valid?
      cred = Ecto.Changeset.apply_changes(changeset)
      assert cred.created_at == nil
      assert cred.credential_type == nil
      assert cred.hashed_data == nil
      assert cred.id == nil
      assert cred.name == nil
      assert cred.updated_at == nil
    end

    test "handles integer timestamps and zero values" do
      params = %{"created_at" => 0, "updated_at" => 0}
      changeset = ConnectorCredential.changeset(%ConnectorCredential{}, params)
      assert changeset.valid?
      cred = Ecto.Changeset.apply_changes(changeset)
      assert cred.created_at == 0
      assert cred.updated_at == 0
    end

    test "creates minimal connector credential with only id and name" do
      params = %{"id" => "cred_123", "name" => "Minimal"}
      changeset = ConnectorCredential.changeset(%ConnectorCredential{}, params)
      assert changeset.valid?
      cred = Ecto.Changeset.apply_changes(changeset)
      assert cred.id == "cred_123"
      assert cred.name == "Minimal"
    end
  end
end
