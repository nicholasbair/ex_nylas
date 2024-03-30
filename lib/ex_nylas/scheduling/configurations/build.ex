defmodule ExNylas.Scheduling.Configuration.Build do
  @moduledoc """
  Helper module for validating a scheduling configuration before sending it.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.{
    Build.AvailabilityRules,
    EventBooking,
    SchedulingParticipant
  }

  @derive {Jason.Encoder, only: [:version, :participants, :availability_rules, :event_booking]}
  @primary_key false

  embedded_schema do
    field :version, :string

    embeds_many :participants, SchedulingParticipant
    embeds_many :availability_rules, AvailabilityRules
    embeds_one :event_booking, EventBooking
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:version])
    |> validate_required([:version])
    |> cast_embed(:availability_rules)
    |> cast_embed(:event_booking, required: true)
    |> cast_embed(:participants, required: true)
  end
end
