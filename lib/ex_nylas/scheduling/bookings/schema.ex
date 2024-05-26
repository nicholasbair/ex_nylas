defmodule ExNylas.Scheduling.Booking do
  @moduledoc """
  A struct representing a scheduling booking.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          booking_id: String.t()
        }

  @primary_key false

  embedded_schema do
    field :booking_id, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:booking_id])
    |> validate_required([:booking_id])
  end
end
