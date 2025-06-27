defmodule ExNylas.Scheduling.ConfigurationTest do
  use ExUnit.Case, async: true
  alias ExNylas.Scheduling.Configuration

  @valid_attrs %{
    id: "conf_123",
    slug: "my-slug",
    requires_session_auth: true,
    availability: %{
      duration_minutes: 30,
      interval_minutes: 15,
      round_to: 5
    },
    scheduler: %{
      additional_fields: %{"foo" => "bar"},
      available_days_in_future: 30,
      cancellation_policy: "strict",
      cancellation_url: "https://example.com/cancel",
      hide_additionl_fields: false,
      hide_cancelation_options: false,
      hide_rescheduling_options: false,
      min_booking_notice: 60,
      min_cancellation_notice: 120,
      rescheduling_url: "https://example.com/reschedule"
      # email_template omitted for shallow test
    },
    event_booking: %{
      event_id: "evt_123",
      status: "confirmed"
    },
    participants: [
      %{email: "test@example.com", name: "Test User"}
    ]
  }

  test "valid changeset with all fields (shallow)" do
    changeset = Configuration.changeset(%Configuration{}, @valid_attrs)
    assert changeset.valid?
    struct = Ecto.Changeset.apply_changes(changeset)
    assert struct.id == "conf_123"
    assert struct.slug == "my-slug"
    assert struct.requires_session_auth == true
    assert struct.availability.duration_minutes == 30
    assert struct.scheduler.available_days_in_future == 30
    assert struct.event_booking != nil
    assert Enum.at(struct.participants, 0).email == "test@example.com"
  end

  test "missing required fields" do
    changeset = Configuration.changeset(%Configuration{}, %{})
    assert changeset.valid?
  end

  test "invalid types are rejected" do
    attrs = Map.put(@valid_attrs, :requires_session_auth, "not_a_bool")
    changeset = Configuration.changeset(%Configuration{}, attrs)
    refute changeset.valid?
    assert {:requires_session_auth, {_, [{:type, :boolean}, {:validation, :cast}]}} = hd(changeset.errors)
  end

  test "invalid nested embed is accepted (shallow)" do
    attrs = put_in(@valid_attrs, [:availability, :duration_minutes], -5)
    changeset = Configuration.changeset(%Configuration{}, attrs)
    # Should still be valid, as non_neg_integer is not enforced at runtime
    assert changeset.valid?
  end

  test "missing nested embed is allowed" do
    attrs = Map.delete(@valid_attrs, :availability)
    changeset = Configuration.changeset(%Configuration{}, attrs)
    assert changeset.valid?
  end

  test "empty participants list is allowed" do
    attrs = Map.put(@valid_attrs, :participants, [])
    changeset = Configuration.changeset(%Configuration{}, attrs)
    assert changeset.valid?
  end

  test "invalid participants are rejected" do
    attrs = Map.put(@valid_attrs, :participants, [%{email: 123}])
    changeset = Configuration.changeset(%Configuration{}, attrs)
    refute changeset.valid?
  end
end
