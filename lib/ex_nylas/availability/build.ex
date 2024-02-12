defmodule ExNylas.Schema.Calendar.Availability.Build do
  @moduledoc """
  Helper module for validating an availability request.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Schema.Calendar.Availability.Build.{
    AvailabilityRules,
    Participant
  }

  @derive {Jason.Encoder, only: [:participants, :start_time, :end_time, :duration_minutes, :interval_minutes, :round_to_30_minutes, :availability_rules]}
  @primary_key false

  schema "availability" do
    field :start_time, :integer
    field :end_time, :integer
    field :duration_minutes, :integer
    field :interval_minutes, :integer
    field :round_to_30_minutes, :boolean

    embeds_many :availability_rules, AvailabilityRules
    embeds_many :participants, Participant
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_time, :end_time, :duration_minutes, :interval_minutes, :round_to_30_minutes])
    |> cast_embed(:availability_rules)
    |> cast_embed(:participants)
    |> validate_required([:participants, :start_time, :end_time, :duration_minutes])
  end
end
