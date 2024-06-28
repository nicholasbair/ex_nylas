defmodule ExNylas.Scheduling.Configuration do
  @moduledoc """
  A struct representing a scheduling configuration.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  alias ExNylas.Common.{
    AvailabilityRules,
    EventBooking,
    SchedulingParticipant
  }

  @primary_key false

  typed_embedded_schema do
    field(:id, :string, null: false)
    field(:requires_session_auth, :boolean, null: false)

    embeds_one :availability, Availability, primary_key: false do
      field(:duration_minutes, :integer) :: non_neg_integer()
      field(:interval_minutes, :integer) :: non_neg_integer()
      field(:round_to_30_minutes, :boolean, null: false)

      embeds_one :availability_rules, AvailabilityRules
    end

    embeds_one :scheduler, Scheduler, primary_key: false do
      field(:available_days_in_future, :integer) :: non_neg_integer()
      field(:cancellation_url, :string)
      field(:min_cancellation_notice, :integer) :: non_neg_integer()
      field(:rescheduling_url, :string)
    end

    embeds_one :event_booking, EventBooking
    embeds_many :participants, SchedulingParticipant
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :requires_session_auth])
    |> validate_required([:id])
    |> cast_embed(:participants)
    |> cast_embed(:event_booking)
    |> cast_embed(:availability, with: &embedded_changeset_availability/2, required: true)
    |> cast_embed(:scheduler, with: &embedded_changeset/2)
  end

  @doc false
  def embedded_changeset_availability(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:duration_minutes, :interval_minutes, :round_to_30_minutes])
    |> cast_embed(:availability_rules)
  end
end
