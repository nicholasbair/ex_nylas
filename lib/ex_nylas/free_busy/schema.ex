defmodule ExNylas.FreeBusy do
  @moduledoc """
  Structs for Nylas calendar free/busy.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field(:email, :string, null: false)
    field(:object, :string, null: false)

    embeds_many :time_slots, TimeSlot, primary_key: false do
      field(:end_time, :integer, null: false) :: non_neg_integer()
      field(:object, :string, null: false)
      field(:start_time, :integer, null: false) :: non_neg_integer()
      field(:status, :string, null: false)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:object, :email])
    |> cast_embed(:time_slots, with: &Util.embedded_changeset/2)
  end
end
