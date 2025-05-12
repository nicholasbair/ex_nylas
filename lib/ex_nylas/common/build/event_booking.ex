defmodule ExNylas.EventBooking.Build do
  @moduledoc """
  Helper module for validating an event booking before sending it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.EventReminder.Build, as: EventReminderBuild
  alias ExNylas.EventConferencing.Build, as: EventConferencingBuild

  @primary_key false
  @derive {Jason.Encoder, only: [:title, :description, :location, :timezone, :booking_type, :additional_fields, :hide_participants, :disable_emails, :conferencing, :reminders]}

  typed_embedded_schema do
    field(:additional_fields, :map)
    field(:booking_type, Ecto.Enum, values: ~w(booking organizer-confirmation custom-confirmation)a)
    field(:description, :string)
    field(:disable_emails, :boolean)
    field(:hide_participants, :boolean)
    field(:location, :string)
    field(:timezone, :string)
    field(:title, :string, null: false)

    embeds_one :conferencing, EventConferencingBuild
    embeds_one :reminders, EventReminderBuild
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :description, :location, :timezone, :booking_type, :additional_fields, :hide_participants, :disable_emails])
    |> cast_embed(:conferencing)
    |> cast_embed(:reminders)
    |> validate_required([:title])
  end
end
