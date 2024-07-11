defmodule ExNylas.Scheduling.Configuration.Build do
  @moduledoc """
  Helper module for validating a scheduling configuration before sending it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Build.{
    Availability,
    EventBooking,
    Scheduler,
    SchedulingParticipant
  }

  @derive {Jason.Encoder, only: [:requires_session_auth, :participants, :availability, :event_booking]}
  @primary_key false

  typed_embedded_schema do
    field(:requires_session_auth, :boolean)

    embeds_one :availability, Availability
    embeds_one :event_booking, EventBooking
    embeds_many :participants, SchedulingParticipant
    embeds_one :scheduler, Scheduler
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:requires_session_auth])
    |> cast_embed(:availability)
    |> cast_embed(:event_booking, required: true)
    |> cast_embed(:participants, required: true)
    |> cast_embed(:scheduler)
  end
end
