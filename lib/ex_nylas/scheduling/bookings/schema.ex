defmodule ExNylas.Scheduling.Booking do
  @moduledoc """
  A struct representing a scheduling booking.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:booking_id, :string, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:booking_id])
    |> validate_required([:booking_id])
  end
end
