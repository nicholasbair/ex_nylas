defmodule ExNylas.Scheduling.Configuration.Build do
  @moduledoc """
  Helper module for validating a scheduling configuration before sending it.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.Build.{
    Availability,
    EventBooking,
    Scheduler,
    SchedulingParticipant
  }

  @derive {Jason.Encoder, only: [:version, :requires_session_auth, :participants, :availability, :event_booking]}
  @primary_key false

  embedded_schema do
    field :version, :string
    field :requires_session_auth, :boolean

    embeds_many :participants, SchedulingParticipant
    embeds_many :availability, Availability
    embeds_one :event_booking, EventBooking
    embeds_one :scheduler, Scheduler
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:version, :requires_session_auth])
    |> validate_required([:version])
    |> cast_embed(:availability)
    |> cast_embed(:event_booking, required: true)
    |> cast_embed(:participants, required: true)
    |> cast_embed(:scheduler)
  end
end
