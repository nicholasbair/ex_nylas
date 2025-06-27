defmodule ExNylas.ApplicationTest do
  use ExUnit.Case, async: true
  alias ExNylas.Application

  describe "Application schema" do
    test "creates a valid application with all fields" do
      params = %{
        "application_id" => "app_123",
        "organization_id" => "org_456",
        "region" => "us",
        "created_at" => 1640995200,
        "updated_at" => 1640995300,
        "environment" => "production",
        "v2_application_id" => "v2_app_789",
        "branding" => %{
          "description" => "Test App",
          "icon_url" => "https://example.com/icon.png",
          "name" => "Test Application",
          "website_url" => "https://example.com"
        },
        "hosted_authentication" => %{
          "alignment" => "center",
          "background_color" => "#FFFFFF",
          "background_image_url" => "https://example.com/bg.png",
          "color_primary" => "#000000",
          "color_secondary" => "#CCCCCC",
          "spacing" => 10,
          "subtitle" => "Welcome!",
          "title" => "Sign In"
        },
        "callback_uris" => [
          %{"url" => "https://example.com/callback"},
          %{"url" => "https://example.com/other"}
        ]
      }

      changeset = Application.changeset(%Application{}, params)
      assert changeset.valid?
      app = Ecto.Changeset.apply_changes(changeset)
      assert app.application_id == "app_123"
      assert app.organization_id == "org_456"
      assert app.region == :us
      assert app.created_at == 1640995200
      assert app.updated_at == 1640995300
      assert app.environment == :production
      assert app.v2_application_id == "v2_app_789"
      assert app.branding.description == "Test App"
      assert app.branding.icon_url == "https://example.com/icon.png"
      assert app.branding.name == "Test Application"
      assert app.branding.website_url == "https://example.com"
      assert app.hosted_authentication.alignment == :center
      assert app.hosted_authentication.background_color == "#FFFFFF"
      assert app.hosted_authentication.background_image_url == "https://example.com/bg.png"
      assert app.hosted_authentication.color_primary == "#000000"
      assert app.hosted_authentication.color_secondary == "#CCCCCC"
      assert app.hosted_authentication.spacing == 10
      assert app.hosted_authentication.subtitle == "Welcome!"
      assert app.hosted_authentication.title == "Sign In"
      assert length(app.callback_uris) == 2
      assert Enum.at(app.callback_uris, 0).url == "https://example.com/callback"
      assert Enum.at(app.callback_uris, 1).url == "https://example.com/other"
    end

    test "validates region enum values" do
      valid_regions = ["us", "eu"]
      for region <- valid_regions do
        params = %{"region" => region}
        changeset = Application.changeset(%Application{}, params)
        assert changeset.valid?, "Region #{region} should be valid"
      end
    end

    test "rejects invalid region values" do
      invalid_regions = ["apac", "global", "invalid"]
      for region <- invalid_regions do
        params = %{"region" => region}
        changeset = Application.changeset(%Application{}, params)
        refute changeset.valid?, "Region #{region} should be invalid"
        app = Ecto.Changeset.apply_changes(changeset)
        assert app.region == nil
      end
    end

    test "validates environment enum values" do
      valid_envs = ["production", "staging", "development", "sandbox"]
      for env <- valid_envs do
        params = %{"environment" => env}
        changeset = Application.changeset(%Application{}, params)
        assert changeset.valid?, "Environment #{env} should be valid"
      end
    end

    test "rejects invalid environment values" do
      invalid_envs = ["test", "qa", "invalid"]
      for env <- invalid_envs do
        params = %{"environment" => env}
        changeset = Application.changeset(%Application{}, params)
        refute changeset.valid?, "Environment #{env} should be invalid"
        app = Ecto.Changeset.apply_changes(changeset)
        assert app.environment == nil
      end
    end

    test "validates hosted_authentication alignment enum values" do
      valid_alignments = ["left", "center", "right"]
      for alignment <- valid_alignments do
        params = %{"hosted_authentication" => %{"alignment" => alignment}}
        changeset = Application.changeset(%Application{}, params)
        assert changeset.valid?, "Alignment #{alignment} should be valid"
      end
    end

    test "rejects invalid hosted_authentication alignment values" do
      invalid_alignments = ["top", "bottom", "invalid"]
      for alignment <- invalid_alignments do
        params = %{"hosted_authentication" => %{"alignment" => alignment}}
        changeset = Application.changeset(%Application{}, params)
        refute changeset.valid?, "Alignment #{alignment} should be invalid"
        app = Ecto.Changeset.apply_changes(changeset)
        assert app.hosted_authentication == nil or app.hosted_authentication.alignment == nil
      end
    end

    test "handles nil values gracefully" do
      params = %{
        "application_id" => nil,
        "organization_id" => nil,
        "region" => nil,
        "created_at" => nil,
        "updated_at" => nil,
        "environment" => nil,
        "v2_application_id" => nil,
        "branding" => nil,
        "hosted_authentication" => nil
      }
      changeset = Application.changeset(%Application{}, params)
      assert changeset.valid?
      app = Ecto.Changeset.apply_changes(changeset)
      assert app.application_id == nil
      assert app.organization_id == nil
      assert app.region == nil
      assert app.created_at == nil
      assert app.updated_at == nil
      assert app.environment == nil
      assert app.v2_application_id == nil
      assert app.branding == nil
      assert app.hosted_authentication == nil
    end

    test "handles empty arrays" do
      params = %{
        "callback_uris" => []
      }
      changeset = Application.changeset(%Application{}, params)
      assert changeset.valid?
      app = Ecto.Changeset.apply_changes(changeset)
      assert app.callback_uris == []
    end
  end
end
