defmodule ExNylas.Notetaker.CustomSettingsTest do
  use ExUnit.Case, async: true
  alias ExNylas.Notetaker.CustomSettings

  describe "CustomSettings schema" do
    test "creates a valid custom settings with custom_instructions" do
      params = %{"custom_instructions" => "Please focus on action items"}
      changeset = CustomSettings.changeset(%CustomSettings{}, params)
      assert changeset.valid?
      settings = Ecto.Changeset.apply_changes(changeset)
      assert settings.custom_instructions == "Please focus on action items"
    end

    test "handles nil custom_instructions" do
      params = %{"custom_instructions" => nil}
      changeset = CustomSettings.changeset(%CustomSettings{}, params)
      assert changeset.valid?
      settings = Ecto.Changeset.apply_changes(changeset)
      assert settings.custom_instructions == nil
    end

    test "creates custom settings with empty map" do
      changeset = CustomSettings.changeset(%CustomSettings{}, %{})
      assert changeset.valid?
    end

    test "JSON encodes only custom_instructions field" do
      settings = %CustomSettings{custom_instructions: "Test instructions"}
      json = Jason.encode!(settings)
      decoded = Jason.decode!(json)
      assert decoded == %{"custom_instructions" => "Test instructions"}
    end
  end
end
