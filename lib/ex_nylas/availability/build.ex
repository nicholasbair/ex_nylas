defmodule ExNylas.CalendarAvailability.Build do
  @moduledoc """
  Helper module for validating an availability request.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.AvailabilityRules.Build, as: AvailabilityRulesBuild

  @derive {Jason.Encoder, only: [:participants, :start_time, :end_time, :duration_minutes, :interval_minutes, :round_to, :availability_rules]}
  @primary_key false

  typed_embedded_schema do
    field(:duration_minutes, :integer) :: non_neg_integer()
    field(:end_time, :integer) :: non_neg_integer()
    field(:interval_minutes, :integer) :: non_neg_integer() | nil
    field(:start_time, :integer) :: non_neg_integer()
    field(:round_to, :integer) :: non_neg_integer()

    embeds_many :availability_rules, AvailabilityRulesBuild

    embeds_many :participants, Participant, primary_key: false do
      @derive {Jason.Encoder, only: [:email, :calendar_ids, :open_hours]}

      field(:calendar_ids, {:array, :string})
      field(:email, :string)

      embeds_many :open_hours, OpenHours, primary_key: false do
        @derive {Jason.Encoder, only: [:days, :timezone, :start, :end, :exdates]}

        field(:days, {:array, :integer})
        field(:end, :string)
        field(:exdates, {:array, :string})
        field(:start, :string)
        field(:timezone, :string)
      end
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_time, :end_time, :duration_minutes, :interval_minutes, :round_to])
    |> cast_embed(:availability_rules)
    |> cast_embed(:participants, with: &participant_changeset/2, required: true)
    |> validate_required([:start_time, :end_time, :duration_minutes])
  end

  @doc false
  def participant_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :calendar_ids])
    |> cast_embed(:open_hours)
  end
end
