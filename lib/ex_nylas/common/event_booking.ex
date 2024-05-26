defmodule ExNylas.Common.EventBooking do
  @moduledoc """
  A struct representing an event booking.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.{
    EventConferencing,
    EventReminder
  }

  @type t :: %__MODULE__{
          title: String.t(),
          location: String.t(),
          description: String.t(),
          booking_type: atom(),
          additional_fields: map(),
          hide_participants: boolean(),
          disable_emails: boolean(),
          conference: EventConferencing.t(),
          reminders: EventReminder.t()
        }

  @primary_key false

  embedded_schema do
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
