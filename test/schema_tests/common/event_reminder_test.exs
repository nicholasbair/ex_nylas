defmodule ExNylas.EventReminderTest do
  use ExUnit.Case, async: true
  alias ExNylas.EventReminder

  describe "EventReminder schema" do
    test "creates a valid event reminder with all fields" do
      params = %{
        "overrides" => [
          %{"method" => "email", "minutes" => 15},
          %{"method" => "popup", "minutes" => 5}
        ],
        "use_default" => false
      }
      changeset = EventReminder.changeset(%EventReminder{}, params)
      assert changeset.valid?
      reminder = Ecto.Changeset.apply_changes(changeset)
      assert reminder.overrides == [
        %{"method" => "email", "minutes" => 15},
        %{"method" => "popup", "minutes" => 5}
      ]
      assert reminder.use_default == false
    end

    test "handles booleans and nil values for use_default" do
      for bool <- [true, false, nil] do
        params = %{"use_default" => bool}
        changeset = EventReminder.changeset(%EventReminder{}, params)
        assert changeset.valid?
        reminder = Ecto.Changeset.apply_changes(changeset)
        assert reminder.use_default == bool
      end
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "overrides" => nil,
        "use_default" => nil
      }
      changeset = EventReminder.changeset(%EventReminder{}, params)
      assert changeset.valid?
      reminder = Ecto.Changeset.apply_changes(changeset)
      assert reminder.overrides == nil
      assert reminder.use_default == nil
    end

    test "creates minimal event reminder with empty params" do
      params = %{}
      changeset = EventReminder.changeset(%EventReminder{}, params)
      assert changeset.valid?
      reminder = Ecto.Changeset.apply_changes(changeset)
      assert reminder.overrides == nil
      assert reminder.use_default == nil
    end
  end
end
