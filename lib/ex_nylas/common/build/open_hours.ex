defmodule ExNylas.Common.Build.OpenHours do
  @moduledoc """
  Helper module for building open hours.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:days, :timezone, :start, :end, :exdates]}

  embedded_schema do
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
