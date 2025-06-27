defmodule ExNylas.ApplicationRedirectTest do
  use ExUnit.Case, async: true
  alias ExNylas.ApplicationRedirect

  describe "ApplicationRedirect schema" do
    test "creates a valid application redirect with all fields" do
      params = %{
        "id" => "redirect_123",
        "platform" => "web",
        "url" => "https://example.com/callback"
      }

      changeset = ApplicationRedirect.changeset(%ApplicationRedirect{}, params)
      assert changeset.valid?
      redirect = Ecto.Changeset.apply_changes(changeset)
      assert redirect.id == "redirect_123"
      assert redirect.platform == :web
      assert redirect.url == "https://example.com/callback"
    end

    test "validates platform enum values" do
      valid_platforms = ["web", "desktop", "js", "ios", "android"]
      for platform <- valid_platforms do
        params = %{"platform" => platform}
        changeset = ApplicationRedirect.changeset(%ApplicationRedirect{}, params)
        assert changeset.valid?, "Platform #{platform} should be valid"
      end
    end

    test "rejects invalid platform values" do
      invalid_platforms = ["mobile", "tablet", "invalid"]
      for platform <- invalid_platforms do
        params = %{"platform" => platform}
        changeset = ApplicationRedirect.changeset(%ApplicationRedirect{}, params)
        refute changeset.valid?, "Platform #{platform} should be invalid"
        redirect = Ecto.Changeset.apply_changes(changeset)
        assert redirect.platform == nil
      end
    end

    test "handles nil values gracefully" do
      params = %{
        "id" => nil,
        "platform" => nil,
        "url" => nil
      }
      changeset = ApplicationRedirect.changeset(%ApplicationRedirect{}, params)
      assert changeset.valid?
      redirect = Ecto.Changeset.apply_changes(changeset)
      assert redirect.id == nil
      assert redirect.platform == nil
      assert redirect.url == nil
    end
  end
end
