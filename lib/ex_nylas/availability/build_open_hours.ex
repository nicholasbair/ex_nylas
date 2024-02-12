defmodule ExNylas.Schema.Calendar.Availability.Build.OpenHours do
  @moduledoc """
  Helper module for validating the open hours subobject on an availability request.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:days, :timezone, :start, :end, :exdates]}

  schema "open_hours" do
    field :days, {:array, :integer}
    field :timezone, :string
    field :start, :string
    field :end, :string
    field :exdates, {:array, :string}
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
