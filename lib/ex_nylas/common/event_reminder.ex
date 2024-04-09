defmodule ExNylas.Common.EventReminder do
  @moduledoc """
  A struct for an event reminder.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :overrides, {:array, :map}
    field :use_default, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:overrides, :use_default])
  end
end
