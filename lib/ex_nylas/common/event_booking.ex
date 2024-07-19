defmodule ExNylas.EventBooking do
  @moduledoc """
  A struct representing an event booking.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.{
    EventConferencing,
    EventReminder
  }

  @primary_key false

  typed_embedded_schema do
    field(:additional_fields, :map)
    field(:booking_type, Ecto.Enum, values: ~w(booking organizer-confirmation custom-confirmation)a)
    field(:description, :string)
    field(:disable_emails, :boolean)
    field(:hide_participants, :boolean)
    field(:location, :string)
    field(:title, :string)
    field(:timezone, :string)

    embeds_one :conferencing, EventConferencing
    embeds_one :reminders, EventReminder
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :location, :description, :booking_type, :additional_fields, :hide_participants, :disable_emails, :timezone])
    |> cast_embed(:conferencing)
    |> cast_embed(:reminders)
  end
end
