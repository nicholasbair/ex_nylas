defmodule ExNylas.Common.Build.EventReminder do
  @moduledoc """
  Helper module for validating an event reminder before creating/updating it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:overrides, :use_default]}

  embedded_schema do
    field :overrides, {:array, :map}
    field :use_default, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:overrides, :use_default])
  end
end
