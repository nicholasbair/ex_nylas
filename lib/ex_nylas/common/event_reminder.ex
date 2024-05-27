defmodule ExNylas.Common.EventReminder do
  @moduledoc """
  A struct for an event reminder.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field :overrides, {:array, :map}
    field :use_default, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:overrides, :use_default])
  end
end
