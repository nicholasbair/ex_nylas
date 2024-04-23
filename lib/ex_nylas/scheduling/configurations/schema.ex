defmodule ExNylas.Scheduling.Configuration do
  @moduledoc """
  A struct representing a scheduling configuration.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.{
    AvailabilityRules,
    EventBooking,
    SchedulingParticipant
  }

  @primary_key false

  embedded_schema do
    field :version, :string
    field :id, :string
    field :requires_session_auth, :boolean

    embeds_one :availability, Availability, primary_key: false do
      field :duration_minutes, :integer
      field :interval_minutes, :integer
      field :round_to_30_minutes, :boolean

      embeds_one :availability_rules, AvailabilityRules
    end

    embeds_one :scheduler, Scheduler, primary_key: false do
      field :available_days_in_future, :integer
      field :min_cancellation_notice, :integer
      field :rescheduling_url, :string
      field :cancellation_url, :string
    end

    embeds_one :event_booking, EventBooking
    embeds_many :participants, SchedulingParticipant
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:version, :id, :requires_session_auth])
    |> validate_required([:id])
    |> cast_embed(:participants)
    |> cast_embed(:event_booking)
    |> cast_embed(:availability, with: &embedded_changeset/2, required: true)
  end

  def embedded_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:duration_minutes, :interval_minutes, :round_to_30_minutes])
    |> cast_embed(:availability_rules)
  end
end
