defmodule ExNylas.Common.Build.EventBooking do
  @moduledoc """
  Helper module for validating an event booking before sending it.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.Build.{
    EventReminder,
    EventConferencing
  }

  @primary_key false

  @derive {Jason.Encoder, only: [:title, :description, :location, :timezone, :booking_type, :additional_fields, :hide_participants, :disable_emails, :conference, :reminders]}

  embedded_schema do
    field :title, :string
    field :description, :string
    field :location, :string
    field :timezone, :string
    field :booking_type, Ecto.Enum, values: ~w(booking)a
    field :additional_fields, :map
    field :hide_participants, :boolean
    field :disable_emails, :boolean

    embeds_one :conference, EventConferencing
    embeds_one :reminders, EventReminder
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :description, :location, :timezone, :booking_type, :additional_fields, :hide_participants, :disable_emails])
    |> cast_embed(:conference)
    |> cast_embed(:reminders)
    |> validate_required([:title])
  end
end
