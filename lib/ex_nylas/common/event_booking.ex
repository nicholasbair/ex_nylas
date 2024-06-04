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
    field(:additional_fields, :map)
    field(:booking_type, Ecto.Enum, values: ~w(booking)a, null: false)
    field(:description, :string)
    field(:disable_emails, :boolean, null: false)
    field(:hide_participants, :boolean, null: false)
    field(:location, :string)
    field(:title, :string, null: false)

    embeds_one :conference, EventConferencing
    embeds_one :reminders, EventReminder
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :location, :description, :booking_type, :additional_fields, :hide_participants, :disable_emails])
    |> cast_embed(:conference)
    |> cast_embed(:reminders)
    |> validate_required([:title])
  end
end
