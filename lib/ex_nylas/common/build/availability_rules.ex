defmodule ExNylas.Common.Build.AvailabilityRules do
  @moduledoc """
  Helper module for building an availability rules.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Common.Build.{
    Buffer,
    OpenHours
  }

  @primary_key false

  @derive {Jason.Encoder, only: [:availability_method, :round_robin_group_id, :buffer, :default_open_hours]}

  typed_embedded_schema do
    field(:availability_method, Ecto.Enum, values: ~w(collective max-fairness max-availability)a)
    field(:round_robin_group_id, :string)

    embeds_one :buffer, Buffer
    embeds_many :default_open_hours, OpenHours
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:availability_method, :round_robin_group_id])
    |> cast_embed(:buffer)
    |> cast_embed(:default_open_hours)
  end
end
