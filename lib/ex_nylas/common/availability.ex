defmodule ExNylas.Common.Availability do
  @moduledoc """
  Struct for Nylas common availability.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @type t :: %__MODULE__{
          order: [String.t()],
          time_slots: [
            %__MODULE__.TimeSlot{
              emails: [String.t()],
              start_time: non_neg_integer(),
              end_time: non_neg_integer()
            }
          ]
        }

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
    |> cast(params, [:order])
    |> cast_embed(:time_slots, with: &Util.embedded_changeset/2)
  end
end
