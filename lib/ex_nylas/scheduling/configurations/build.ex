defmodule ExNylas.Scheduling.Configuration.Build do
  @moduledoc """
  Helper module for validating a scheduling configuration before sending it.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/scheduler/)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Availability.Build, as: AvailabilityBuild
  alias ExNylas.EventBooking.Build, as: EventBookingBuild
  alias ExNylas.Scheduler.Build, as: SchedulerBuild
  alias ExNylas.SchedulingParticipant.Build, as: SchedulingParticipantBuild

  @derive {Jason.Encoder, only: [:requires_session_auth, :slug, :participants, :availability, :event_booking, :scheduler]}
  @primary_key false

  typed_embedded_schema do
    field(:requires_session_auth, :boolean)
    field(:slug, :string)

    embeds_one :availability, AvailabilityBuild
    embeds_one :event_booking, EventBookingBuild
    embeds_many :participants, SchedulingParticipantBuild
    embeds_one :scheduler, SchedulerBuild
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:requires_session_auth, :slug])
    |> cast_embed(:availability)
    |> cast_embed(:event_booking, required: true)
    |> cast_embed(:participants, required: true)
    |> cast_embed(:scheduler)
  end
end
