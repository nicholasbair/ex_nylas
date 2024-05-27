defmodule ExNylas.Common.EventBooking do
  @moduledoc """
  A struct representing an event booking.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Common.{
    EventConferencing,
    EventReminder
  }

  @primary_key false

  typed_embedded_schema do
    field :title, :string
    field :location, :string
    field :description, :string
    field :booking_type, Ecto.Enum, values: ~w(booking)a
    field :additional_fields, :map
    field :hide_participants, :boolean
    field :disable_emails, :boolean

    embeds_one :conference, EventConferencing
    embeds_one :reminders, EventReminder
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :location, :description, :booking_type, :additional_fields, :hide_participants, :disable_emails])
    |> cast_embed(:conference)
    |> cast_embed(:reminders)
    |> validate_required([:title])
  end
end
