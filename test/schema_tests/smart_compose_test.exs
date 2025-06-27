defmodule ExNylas.Schema.SmartComposeTest do
  use ExUnit.Case, async: true
  alias ExNylas.Schema.SmartCompose

  describe "SmartCompose schema" do
    test "creates a valid smart compose with suggestion" do
      params = %{
        "suggestion" => "Thank you for your email. I'll get back to you soon."
      }
      changeset = SmartCompose.changeset(%SmartCompose{}, params)
      assert changeset.valid?
      smart_compose = Ecto.Changeset.apply_changes(changeset)
      assert smart_compose.suggestion == "Thank you for your email. I'll get back to you soon."
    end

    test "handles nil suggestion" do
      params = %{"suggestion" => nil}
      changeset = SmartCompose.changeset(%SmartCompose{}, params)
      assert changeset.valid?
      smart_compose = Ecto.Changeset.apply_changes(changeset)
      assert smart_compose.suggestion == nil
    end

    test "handles empty string suggestion" do
      params = %{"suggestion" => ""}
      changeset = SmartCompose.changeset(%SmartCompose{}, params)
      assert changeset.valid?
      smart_compose = Ecto.Changeset.apply_changes(changeset)
      assert smart_compose.suggestion == nil
    end

    test "handles long suggestion text" do
      long_text = String.duplicate("This is a very long suggestion text. ", 100)
      params = %{"suggestion" => long_text}
      changeset = SmartCompose.changeset(%SmartCompose{}, params)
      assert changeset.valid?
      smart_compose = Ecto.Changeset.apply_changes(changeset)
      assert smart_compose.suggestion == long_text
    end

    test "creates minimal smart compose with empty params" do
      params = %{}
      changeset = SmartCompose.changeset(%SmartCompose{}, params)
      assert changeset.valid?
      smart_compose = Ecto.Changeset.apply_changes(changeset)
      assert smart_compose.suggestion == nil
    end
  end
end
