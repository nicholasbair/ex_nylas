defmodule ExNylas.WebhookNotification.Booking do
  @moduledoc """
  A struct representing a grant webhook notification.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field(:configuration_id, :string)
    field(:booking_id, :string)
    field(:booking_ref, :string)
    field(:booking_type, :string)
    field(:object, :string)

    embeds_one :booking_info, BookingInfo, primary_key: false do
      field(:event_id, :string)
      field(:old_start_time, :integer)
      field(:old_end_time, :integer)
      field(:start_time, :integer)
      field(:end_time, :integer)
      field(:additional_fields, :map)
      field(:hide_cancellation_options, :boolean)
      field(:hide_rescheduling_options, :boolean)
      field(:title, :string)
      field(:duration, :integer)
      field(:location, :string)
      field(:organizer_timezone, :string)
      field(:guest_timezone, :string)
      field(:cancellation_reason, :string)

      embeds_many :participants, Participant do
        field(:email, :string)
        field(:name, :string)
      end
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:configuration_id, :booking_id, :booking_ref, :booking_type, :object])
    |> cast_embed(:booking_info, with: &Util.embedded_changeset/2)
    |> cast_embed(:participants, with: &Util.embedded_changeset/2)
  end
end
