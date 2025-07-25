defmodule ExNylas.FreeBusy do
  @moduledoc """
  Structs for Nylas calendar free/busy.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/calendar)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field(:email, :string)
    field(:object, :string)

    embeds_many :time_slots, TimeSlot, primary_key: false do
      field(:end_time, :integer) :: non_neg_integer() | nil
      field(:object, :string)
      field(:start_time, :integer) :: non_neg_integer() | nil
      field(:status, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:object, :email])
    |> cast_embed(:time_slots, with: &Util.embedded_changeset/2)
  end
end
