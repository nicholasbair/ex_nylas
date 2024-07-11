defmodule ExNylas.Build.Availability do
  @moduledoc """
  Helper module for building an availability request.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Build.{
    AvailabilityRules,
  }

  @primary_key false
  @derive {Jason.Encoder, only: [:duration_minutes, :interval_minutes, :round_to, :availability_rules]}

  typed_embedded_schema do
    field(:duration_minutes, :integer) :: non_neg_integer()
    field(:interval_minutes, :integer) :: non_neg_integer()
    field(:round_to, :integer) :: non_neg_integer()

    embeds_one :availability_rules, AvailabilityRules
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:duration_minutes, :interval_minutes, :round_to])
    |> validate_required([:duration_minutes])
    |> cast_embed(:availability_rules)
  end
end
