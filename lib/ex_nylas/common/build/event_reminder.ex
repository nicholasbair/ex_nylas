defmodule ExNylas.EventReminder.Build do
  @moduledoc """
  Helper module for validating an event reminder before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:overrides, :use_default]}

  typed_embedded_schema do
    field(:overrides, {:array, :map})
    field(:use_default, :boolean)
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:overrides, :use_default])
  end
end
