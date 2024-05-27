defmodule ExNylas.Common.OpenHours do
  @moduledoc """
  A struct for open hours.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field :days, {:array, :integer}
    field :timezone, :string
    field :start, :string
    field :end, :string
    field :exdates, {:array, :string}
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:days, :timezone, :start, :end, :exdates])
  end

end
