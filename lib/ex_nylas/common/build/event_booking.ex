defmodule ExNylas.Common.Build.EventBooking do
  @moduledoc """
  A struct representing an event booking.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.Build.{
    EventReminder,
    EventConferencing
  }

  @primary_key false

  @derive {Jason.Encoder, only: [:title, :location, :description, :booking_type, :additional_fields, :hide_participants, :conference, :reminders]}

  embedded_schema do
    field :title, :string
    field :location, :string
    field :description, :string
    field :booking_type, Ecto.Enum, values: ~w(booking)a
    field :additional_fields, :map
    field :hide_participants, :boolean

    embeds_one :conference, EventConferencing
    embeds_one :reminders, EventReminder
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :location, :description, :booking_type, :additional_fields, :hide_participants])
    |> cast_embed(:conference)
    |> cast_embed(:reminders)
    |> validate_required([:title])
  end
end