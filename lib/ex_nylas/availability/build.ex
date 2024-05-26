defmodule ExNylas.CalendarAvailability.Build do
  @moduledoc """
  Helper module for validating an availability request.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.Build.AvailabilityRules

  @type t :: %__MODULE__{
          start_time: non_neg_integer(),
          end_time: non_neg_integer(),
          duration_minutes: non_neg_integer(),
          interval_minutes: non_neg_integer(),
          round_to_30_minutes: boolean(),
          availability_rules: [AvailabilityRules.t()],
          participants: [
            %__MODULE__.Participant{
              email: String.t(),
              calendar_ids: [String.t()],
              open_hours: [
                %__MODULE__.Participant.OpenHours{
                  days: [integer()],
                  timezone: String.t(),
                  start: String.t(),
                  end: String.t(),
                  exdates: [String.t()]
                }
              ]
            }
          ]
        }

  @derive {Jason.Encoder, only: [:participants, :start_time, :end_time, :duration_minutes, :interval_minutes, :round_to_30_minutes, :availability_rules]}
  @primary_key false

  embedded_schema do
    field :start_time, :integer
    field :end_time, :integer
    field :duration_minutes, :integer
    field :interval_minutes, :integer
    field :round_to_30_minutes, :boolean

    embeds_many :availability_rules, AvailabilityRules

    embeds_many :participants, Participant, primary_key: false do
      @derive {Jason.Encoder, only: [:email, :calendar_ids, :open_hours]}

      field :email, :string
      field :calendar_ids, {:array, :string}

      embeds_many :open_hours, OpenHours, primary_key: false do
        @derive {Jason.Encoder, only: [:days, :timezone, :start, :end, :exdates]}

        field :days, {:array, :integer}
        field :timezone, :string
        field :start, :string
        field :end, :string
        field :exdates, {:array, :string}
      end
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_time, :end_time, :duration_minutes, :interval_minutes, :round_to_30_minutes])
    |> cast_embed(:availability_rules)
    |> cast_embed(:participants, with: &participant_changeset/2, required: true)
    |> validate_required([:start_time, :end_time, :duration_minutes])
  end

  def participant_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :calendar_ids])
    |> cast_embed(:open_hours)
  end
end
