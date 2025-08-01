defmodule ExNylas.Event.Date do
  @moduledoc """
  A struct representing an event date.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/events)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:date, :string)
    field(:object, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :object])
  end
end
