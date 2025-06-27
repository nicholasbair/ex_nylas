defmodule ExNylas.OpenHoursTest do
  use ExUnit.Case, async: true
  alias ExNylas.OpenHours

  describe "OpenHours schema" do
    test "creates a valid open hours with all fields" do
      params = %{
        "days" => [1, 2, 3, 4, 5],
        "end" => "17:00",
        "exdates" => ["2024-01-01", "2024-12-25"],
        "start" => "09:00",
        "timezone" => "America/Los_Angeles"
      }
      changeset = OpenHours.changeset(%OpenHours{}, params)
      assert changeset.valid?
      open_hours = Ecto.Changeset.apply_changes(changeset)
      assert open_hours.days == [1, 2, 3, 4, 5]
      assert open_hours.end == "17:00"
      assert open_hours.exdates == ["2024-01-01", "2024-12-25"]
      assert open_hours.start == "09:00"
      assert open_hours.timezone == "America/Los_Angeles"
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "days" => nil,
        "end" => nil,
        "exdates" => nil,
        "start" => nil,
        "timezone" => nil
      }
      changeset = OpenHours.changeset(%OpenHours{}, params)
      assert changeset.valid?
      open_hours = Ecto.Changeset.apply_changes(changeset)
      assert open_hours.days == nil
      assert open_hours.end == nil
      assert open_hours.exdates == nil
      assert open_hours.start == nil
      assert open_hours.timezone == nil
    end

    test "handles empty arrays" do
      params = %{
        "days" => [],
        "exdates" => []
      }
      changeset = OpenHours.changeset(%OpenHours{}, params)
      assert changeset.valid?
      open_hours = Ecto.Changeset.apply_changes(changeset)
      assert open_hours.days == []
      assert open_hours.exdates == []
    end

    test "handles integer values for days" do
      valid_days = [0, 1, 2, 3, 4, 5, 6, 7]
      for day <- valid_days do
        params = %{"days" => [day]}
        changeset = OpenHours.changeset(%OpenHours{}, params)
        assert changeset.valid?, "Day #{day} should be valid"
        open_hours = Ecto.Changeset.apply_changes(changeset)
        assert open_hours.days == [day]
      end
    end

    test "creates minimal open hours with only start and end" do
      params = %{"start" => "09:00", "end" => "17:00"}
      changeset = OpenHours.changeset(%OpenHours{}, params)
      assert changeset.valid?
      open_hours = Ecto.Changeset.apply_changes(changeset)
      assert open_hours.start == "09:00"
      assert open_hours.end == "17:00"
    end
  end
end
