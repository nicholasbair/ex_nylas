defmodule ExNylas.Common.Availability do
  @moduledoc """
  Struct for Nylas common availability.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field :order, {:array, :string}

    embeds_many :time_slots, TimeSlot, primary_key: false do
      field :emails, {:array, :string}
      field :start_time, :integer
      field :end_time, :integer
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:order])
    |> cast_embed(:time_slots, with: &Util.embedded_changeset/2)
  end
end
