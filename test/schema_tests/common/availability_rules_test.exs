defmodule ExNylas.AvailabilityRulesTest do
  use ExUnit.Case, async: true
  alias ExNylas.AvailabilityRules

  describe "AvailabilityRules schema" do
    test "creates a valid availability rules with all fields" do
      params = %{
        "availability_method" => "collective",
        "round_robin_group_id" => "group_123",
        "buffer" => %{
          "after" => 1000,
          "before" => 500
        },
        "default_open_hours" => [
          %{
            "days" => [1, 2, 3, 4, 5],
            "end" => "17:00",
            "start" => "09:00",
            "timezone" => "America/New_York"
          },
          %{
            "days" => [6],
            "end" => "12:00",
            "start" => "10:00",
            "timezone" => "America/New_York"
          }
        ]
      }
      changeset = AvailabilityRules.changeset(%AvailabilityRules{}, params)
      assert changeset.valid?
      rules = Ecto.Changeset.apply_changes(changeset)
      assert rules.availability_method == :collective
      assert rules.round_robin_group_id == "group_123"
      assert rules.buffer.after == 1000
      assert rules.buffer.before == 500
      assert length(rules.default_open_hours) == 2

      [first_hours, second_hours] = rules.default_open_hours
      assert first_hours.days == [1, 2, 3, 4, 5]
      assert first_hours.end == "17:00"
      assert first_hours.start == "09:00"
      assert first_hours.timezone == "America/New_York"
      assert second_hours.days == [6]
      assert second_hours.end == "12:00"
      assert second_hours.start == "10:00"
      assert second_hours.timezone == "America/New_York"
    end

    test "handles all valid availability_method enum values" do
      valid_methods = ["collective", "max-fairness", "max-availability"]

      for method <- valid_methods do
        params = %{"availability_method" => method}
        changeset = AvailabilityRules.changeset(%AvailabilityRules{}, params)
        assert changeset.valid?, "Availability method #{method} should be valid"
        rules = Ecto.Changeset.apply_changes(changeset)
        assert rules.availability_method == String.to_atom(method)
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "availability_method" => nil,
        "round_robin_group_id" => nil,
        "buffer" => nil,
        "default_open_hours" => nil
      }
      changeset = AvailabilityRules.changeset(%AvailabilityRules{}, params)
      refute changeset.valid?
    end

    test "handles empty default_open_hours array" do
      params = %{
        "availability_method" => "max-fairness",
        "default_open_hours" => []
      }
      changeset = AvailabilityRules.changeset(%AvailabilityRules{}, params)
      assert changeset.valid?
      rules = Ecto.Changeset.apply_changes(changeset)
      assert rules.default_open_hours == []
    end

    test "handles partial buffer data" do
      params = %{
        "availability_method" => "max-availability",
        "buffer" => %{
          "after" => 1000
        }
      }
      changeset = AvailabilityRules.changeset(%AvailabilityRules{}, params)
      assert changeset.valid?
      rules = Ecto.Changeset.apply_changes(changeset)
      assert rules.buffer.after == 1000
      assert rules.buffer.before == nil
    end

    test "handles partial open hours data" do
      params = %{
        "availability_method" => "collective",
        "default_open_hours" => [
          %{
            "days" => [1, 2, 3],
            "start" => "09:00"
          }
        ]
      }
      changeset = AvailabilityRules.changeset(%AvailabilityRules{}, params)
      assert changeset.valid?
      rules = Ecto.Changeset.apply_changes(changeset)
      assert length(rules.default_open_hours) == 1
      hours = List.first(rules.default_open_hours)
      assert hours.days == [1, 2, 3]
      assert hours.start == "09:00"
      assert hours.end == nil
      assert hours.timezone == nil
    end

    test "creates minimal rules with only availability_method" do
      params = %{"availability_method" => "collective"}
      changeset = AvailabilityRules.changeset(%AvailabilityRules{}, params)
      assert changeset.valid?
      rules = Ecto.Changeset.apply_changes(changeset)
      assert rules.availability_method == :collective
      assert rules.round_robin_group_id == nil
      assert rules.buffer == nil
      assert rules.default_open_hours == []
    end

    test "handles special characters in round_robin_group_id" do
      params = %{
        "availability_method" => "max-fairness",
        "round_robin_group_id" => "group-123_abc@test"
      }
      changeset = AvailabilityRules.changeset(%AvailabilityRules{}, params)
      assert changeset.valid?
      rules = Ecto.Changeset.apply_changes(changeset)
      assert rules.round_robin_group_id == "group-123_abc@test"
    end

    test "creates empty rules" do
      params = %{}
      changeset = AvailabilityRules.changeset(%AvailabilityRules{}, params)
      # Note: availability_method is not required by the schema
      assert changeset.valid?
      rules = Ecto.Changeset.apply_changes(changeset)
      assert rules.availability_method == nil
      assert rules.round_robin_group_id == nil
      assert rules.buffer == nil
      assert rules.default_open_hours == []
    end
  end
end
