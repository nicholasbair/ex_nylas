defmodule ExNylas.Scheduling.Configuration do
  @moduledoc """
  A struct representing a scheduling configuration.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]
  alias ExNylas.Common.{
    AvailabilityRules,
    EventBooking,
    SchedulingParticipant
  }

  @primary_key false

  embedded_schema do
    field :version, :string
    field :id, :string

    embeds_one :availability, Availability, primary_key: false do
      field :duration_minutes, :integer
      field :interval_minutes, :integer
      field :round_to_30_minutes, :boolean

      embeds_many :availability_rules, AvailabilityRules
    end

    embeds_one :booking, EventBooking
    embeds_many :participants, SchedulingParticipant
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:version, :id])
    |> validate_required([:id])
    |> cast_embed(:participants)
    |> cast_embed(:booking)
    |> cast_embed(:availability, with: &embedded_changeset/2, required: true)
  end
end