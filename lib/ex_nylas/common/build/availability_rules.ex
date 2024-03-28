defmodule ExNylas.Common.Build.AvailabilityRules do
  @moduledoc """
  A struct for availability rules.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false
  @derive {Jason.Encoder, only: [:availability_method, :round_robin_group_id, :buffer, :default_open_hours]}

  embedded_schema do
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

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:availability_method, :round_robin_group_id])
    |> cast_embed(:buffer, with: &embedded_changeset/2)
    |> cast_embed(:default_open_hours, with: &embedded_changeset/2)
  end
end
