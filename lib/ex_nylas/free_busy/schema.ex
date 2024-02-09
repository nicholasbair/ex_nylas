defmodule ExNylas.Schema.Calendar.FreeBusy do
  @moduledoc """
  Structs for Nylas calendar free/busy.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  schema "free_busy" do
    field :object, :string
    field :email, :string

    embeds_many :time_slots, TimeSlot do
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
