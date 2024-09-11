defmodule ExNylas.Event.Time do
  @moduledoc """
  A struct representing an event time.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:time, :integer) :: non_neg_integer() | nil
    field(:object, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:time, :object])
  end
end
