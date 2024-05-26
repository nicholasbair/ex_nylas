defmodule ExNylas.Common.Build.Availability do
  @moduledoc """
  Helper module for building an availability request.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.Build.{
    AvailabilityRules,
  }

  @type t :: %__MODULE__{
          duration_minutes: non_neg_integer(),
          interval_minutes: non_neg_integer(),
          round_to_30_minutes: boolean(),
          availability_rules: AvailabilityRules.t()
        }

  @primary_key false
  @derive {Jason.Encoder, only: [:duration_minutes, :interval_minutes, :round_to_30_minutes, :availability_rules]}

  embedded_schema do
    field :duration_minutes, :integer
    field :interval_minutes, :integer
    field :round_to_30_minutes, :boolean

    embeds_one :availability_rules, AvailabilityRules
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:duration_minutes, :interval_minutes, :round_to_30_minutes])
    |> validate_required([:duration_minutes])
    |> cast_embed(:availability_rules)
  end
end
