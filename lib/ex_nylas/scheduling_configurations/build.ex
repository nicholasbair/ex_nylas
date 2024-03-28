defmodule ExNylas.SchedulingConfiguration.Build do
  @moduledoc """
  Helper module for validating a scheduling configuration before sending it.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]
  alias ExNylas.Common.Build.AvailabilityRules
  alias ExNylas.Common.SchedulingParticipant, as: Participant
  alias ExNylas.Common.EventBooking

  @derive {Jason.Encoder, only: [:version, :participants, :availability_rules, :event_booking]}
  @primary_key false

  embedded_schema do
    field :version, :string

    embeds_many :participants, Participant
    embeds_many :availability_rules, AvailabilityRules
    embeds_one :event_booking, EventBooking
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:version])
    |> validate_required([:version])
    |> cast_embed(:availability_rules)
    |> cast_embed(:event_booking, with: &embedded_changeset/2, required: true)
    |> cast_embed(:participants, with: &embedded_changeset/2, required: true)
  end
end
