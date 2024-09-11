defmodule ExNylas.Event.Datespan do
  @moduledoc """
  A struct representing an event datespan.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:start_date, :string)
    field(:end_date, :string)
    field(:object, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_date, :end_date, :object])
  end
end
