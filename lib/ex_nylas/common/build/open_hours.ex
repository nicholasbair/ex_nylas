defmodule ExNylas.Common.Build.OpenHours do
  @moduledoc """
  Helper module for building open hours.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:days, :timezone, :start, :end, :exdates]}

  typed_embedded_schema do
    field(:days, {:array, :integer})
    field(:timezone, :string)
    field(:start, :string) :: non_neg_integer()
    field(:end, :string) :: non_neg_integer()
    field(:exdates, {:array, :string})
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:days, :timezone, :start, :end, :exdates])
  end
end
