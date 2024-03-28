defmodule ExNylas.Common.EventBooking do
  @moduledoc """
  A struct representing an event booking.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.Build.EventReminder
  alias ExNylas.Common.Build.EventConferencing

  @primary_key false

  embedded_schema do
    field :title, :string
    field :location, :string
    field :description, :string
    field :booking_type, Ecto.Enum, values: [:booking]
    field :additional_fields, :map
    field :hide_participants, :boolean

    embeds_one :conference, EventConferencing
    embeds_one :reminders, EventReminder
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :location, :description, :booking_type, :additional_fields, :hide_participants])
    |> validate_required([:title, :location, :description, :booking_type, :additional_fields, :hide_participants])
    |> cast_embed(:conference)
    |> cast_embed(:reminders)
  end
end
