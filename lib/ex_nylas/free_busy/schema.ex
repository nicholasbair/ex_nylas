defmodule ExNylas.FreeBusy do
  @moduledoc """
  Structs for Nylas calendar free/busy.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @type t :: %__MODULE__{
          object: String.t(),
          email: String.t(),
          time_slots: [
            %__MODULE__.TimeSlot{
              object: String.t(),
              status: String.t(),
              start_time: non_neg_integer(),
              end_time: non_neg_integer()
            }
          ]
        }

  @primary_key false

  embedded_schema do
    field :object, :string
    field :email, :string

    embeds_many :time_slots, TimeSlot, primary_key: false do
      field :object, :string
      field :status, :string
      field :start_time, :integer
      field :end_time, :integer
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:object, :email])
    |> cast_embed(:time_slots, with: &Util.embedded_changeset/2)
  end
end
