defmodule ExNylas.Availability do
  @moduledoc """
  Structs for Nylas calendar availability.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  embedded_schema do
    field :order, {:array, :string}

    embeds_many :time_slots, TimeSlot, primary_key: false do
      field :emails, {:array, :string}
      field :start_time, :integer
      field :end_time, :integer
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> cast_embed(:time_slots, with: &Util.embedded_changeset/2)
  end
end
