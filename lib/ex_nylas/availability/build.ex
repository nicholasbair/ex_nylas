defmodule ExNylas.CalendarAvailability.Build do
  @moduledoc """
  Helper module for validating an availability request.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @derive {Jason.Encoder, only: [:participants, :start_time, :end_time, :duration_minutes, :interval_minutes, :round_to_30_minutes, :availability_rules]}
  @primary_key false

  embedded_schema do
    field :start_time, :integer
    field :end_time, :integer
    field :duration_minutes, :integer
    field :interval_minutes, :integer
    field :round_to_30_minutes, :boolean

    embeds_many :availability_rules, AvailabilityRules, primary_key: false do
      @derive {Jason.Encoder, only: [:availability_method, :round_robin_group_id, :buffer, :default_open_hours]}

      field :availability_method, Ecto.Enum, values: ~w(collective max-fairness max-availability)a
      field :round_robin_group_id, :string

      embeds_one :buffer, Buffer, primary_key: false do
        @derive {Jason.Encoder, only: [:before, :after]}

        field :before, :integer
        field :after, :integer
      end

      embeds_many :default_open_hours, OpenHours, primary_key: false do
        @derive {Jason.Encoder, only: [:days, :timezone, :start, :end, :exdates]}

        field :days, {:array, :integer}
        field :timezone, :string
        field :start, :string
        field :end, :string
        field :exdates, {:array, :string}
      end
    end

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
    |> cast_embed(:availability_rules, with: &rules_changeset/2)
    |> cast_embed(:participants, with: &participant_changeset/2, required: true)
    |> validate_required([:start_time, :end_time, :duration_minutes])
  end

  def rules_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> cast_embed(:buffer, with: &embedded_changeset/2)
    |> cast_embed(:default_open_hours)
  end

  def participant_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :calendar_ids])
    |> cast_embed(:open_hours)
  end
end
