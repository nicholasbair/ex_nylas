defmodule ExNylas.TrackingOptionsTest do
  use ExUnit.Case, async: true
  alias ExNylas.TrackingOptions

  describe "TrackingOptions schema" do
    test "creates a valid tracking options with all fields" do
      params = %{
        "label" => "Campaign Tracking",
        "links" => true,
        "opens" => false,
        "thread_replies" => true
      }
      changeset = TrackingOptions.changeset(%TrackingOptions{}, params)
      assert changeset.valid?
      options = Ecto.Changeset.apply_changes(changeset)
      assert options.label == "Campaign Tracking"
      assert options.links == true
      assert options.opens == false
      assert options.thread_replies == true
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "label" => nil,
        "links" => nil,
        "opens" => nil,
        "thread_replies" => nil
      }
      changeset = TrackingOptions.changeset(%TrackingOptions{}, params)
      assert changeset.valid?
      options = Ecto.Changeset.apply_changes(changeset)
      assert options.label == nil
      assert options.links == nil
      assert options.opens == nil
      assert options.thread_replies == nil
    end

    test "handles empty string for label" do
      params = %{"label" => ""}
      changeset = TrackingOptions.changeset(%TrackingOptions{}, params)
      assert changeset.valid?
      options = Ecto.Changeset.apply_changes(changeset)
      assert options.label == nil
    end

    test "handles boolean field combinations" do
      test_cases = [
        {true, true, true},
        {true, true, false},
        {true, false, true},
        {true, false, false},
        {false, true, true},
        {false, true, false},
        {false, false, true},
        {false, false, false}
      ]

      for {links, opens, thread_replies} <- test_cases do
        params = %{
          "links" => links,
          "opens" => opens,
          "thread_replies" => thread_replies
        }
        changeset = TrackingOptions.changeset(%TrackingOptions{}, params)
        assert changeset.valid?, "Boolean combination should be valid"
        options = Ecto.Changeset.apply_changes(changeset)
        assert options.links == links
        assert options.opens == opens
        assert options.thread_replies == thread_replies
      end
    end

    test "handles special characters in label" do
      params = %{
        "label" => "Tracking with @#$% symbols & spaces",
        "links" => true
      }
      changeset = TrackingOptions.changeset(%TrackingOptions{}, params)
      assert changeset.valid?
      options = Ecto.Changeset.apply_changes(changeset)
      assert options.label == "Tracking with @#$% symbols & spaces"
    end

    test "creates minimal options with only label" do
      params = %{"label" => "Test Label"}
      changeset = TrackingOptions.changeset(%TrackingOptions{}, params)
      assert changeset.valid?
      options = Ecto.Changeset.apply_changes(changeset)
      assert options.label == "Test Label"
      assert options.links == nil
      assert options.opens == nil
      assert options.thread_replies == nil
    end

    test "creates minimal options with only boolean fields" do
      params = %{
        "links" => true,
        "opens" => false,
        "thread_replies" => true
      }
      changeset = TrackingOptions.changeset(%TrackingOptions{}, params)
      assert changeset.valid?
      options = Ecto.Changeset.apply_changes(changeset)
      assert options.label == nil
      assert options.links == true
      assert options.opens == false
      assert options.thread_replies == true
    end

    test "creates empty tracking options" do
      params = %{}
      changeset = TrackingOptions.changeset(%TrackingOptions{}, params)
      assert changeset.valid?
      options = Ecto.Changeset.apply_changes(changeset)
      assert options.label == nil
      assert options.links == nil
      assert options.opens == nil
      assert options.thread_replies == nil
    end

    test "handles string boolean values" do
      params = %{
        "links" => "true",
        "opens" => "false",
        "thread_replies" => "true"
      }
      changeset = TrackingOptions.changeset(%TrackingOptions{}, params)
      assert changeset.valid?
      options = Ecto.Changeset.apply_changes(changeset)
      assert options.links == true
      assert options.opens == false
      assert options.thread_replies == true
    end
  end
end
