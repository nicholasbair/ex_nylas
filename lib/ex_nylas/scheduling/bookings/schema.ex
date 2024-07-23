defmodule ExNylas.Scheduling.Booking do
  @moduledoc """
  A struct representing a scheduling booking.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:booking_id, :string)
    field(:event_id, :string)
    field(:title, :string)
    field(:description, :string)
    field(:status, Ecto.Enum, values: ~w(booked pending canceled)a)

    embeds_one :organizer, Organizer, primary_key: false do
      field(:email, :string)
      field(:name, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:booking_id, :event_id, :title, :description, :status])
    |> cast_embed(:organizer, with: &embedded_changeset/2)
  end
end
