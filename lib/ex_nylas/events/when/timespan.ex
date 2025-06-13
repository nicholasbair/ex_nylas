defmodule ExNylas.Event.Timespan do
  @moduledoc """
  A struct representing an event timespan.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/events)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:start_time, :integer) :: non_neg_integer() | nil
    field(:end_time, :integer) :: non_neg_integer() | nil
    field(:start_timezone, :string)
    field(:end_timezone, :string)
    field(:object, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_time, :end_time, :start_timezone, :end_timezone, :object])
  end
end
