defmodule ExNylas.ProviderTest do
  use ExUnit.Case, async: true
  alias ExNylas.Provider

  describe "Provider schema" do
    test "creates a valid provider with all fields" do
      params = %{
        "email_address" => "user@example.com",
        "detected" => true,
        "provider" => "google",
        "type" => "gmail"
      }
      changeset = Provider.changeset(%Provider{}, params)
      assert changeset.valid?
      provider = Ecto.Changeset.apply_changes(changeset)
      assert provider.email_address == "user@example.com"
      assert provider.detected == true
      assert provider.provider == :google
      assert provider.type == "gmail"
    end

    test "validates provider enum values" do
      valid_providers = ["google", "microsoft", "imap", "icloud", "yahoo", "ews"]
      for provider <- valid_providers do
        params = %{"provider" => provider}
        changeset = Provider.changeset(%Provider{}, params)
        assert changeset.valid?, "Provider #{provider} should be valid"
        provider_struct = Ecto.Changeset.apply_changes(changeset)
        assert provider_struct.provider == String.to_atom(provider)
      end
    end

    test "rejects invalid provider values" do
      invalid_providers = ["dropbox", "slack", "invalid"]
      for provider <- invalid_providers do
        params = %{"provider" => provider}
        changeset = Provider.changeset(%Provider{}, params)
        refute changeset.valid?, "Provider #{provider} should be invalid"
      end
    end

    test "handles booleans and nil values for boolean fields" do
      for bool <- [true, false, nil] do
        params = %{"detected" => bool}
        changeset = Provider.changeset(%Provider{}, params)
        assert changeset.valid?
        provider = Ecto.Changeset.apply_changes(changeset)
        assert provider.detected == bool
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "email_address" => nil,
        "detected" => nil,
        "provider" => nil,
        "type" => nil
      }
      changeset = Provider.changeset(%Provider{}, params)
      assert changeset.valid?
      provider = Ecto.Changeset.apply_changes(changeset)
      assert provider.email_address == nil
      assert provider.detected == nil
      assert provider.provider == nil
      assert provider.type == nil
    end

    test "creates minimal provider with only email_address" do
      params = %{"email_address" => "user@example.com"}
      changeset = Provider.changeset(%Provider{}, params)
      assert changeset.valid?
      provider = Ecto.Changeset.apply_changes(changeset)
      assert provider.email_address == "user@example.com"
    end
  end
end
