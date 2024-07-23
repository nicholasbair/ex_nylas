defmodule ExNylas.Scheduling.Configuration do
  @moduledoc """
  A struct representing a scheduling configuration.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  alias ExNylas.{
    AvailabilityRules,
    EventBooking,
    SchedulingParticipant
  }

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:slug, :string)
    field(:requires_session_auth, :boolean)

    embeds_one :availability, Availability, primary_key: false do
      field(:duration_minutes, :integer) :: non_neg_integer() | nil
      field(:interval_minutes, :integer) :: non_neg_integer() | nil
      field(:round_to, :integer) :: non_neg_integer() | nil

      embeds_one :availability_rules, AvailabilityRules
    end

    embeds_one :scheduler, Scheduler, primary_key: false do
      field(:additional_fields, :map)
      field(:available_days_in_future, :integer) :: non_neg_integer() | nil
      field(:cancellation_policy, :string)
      field(:cancellation_url, :string)
      field(:hide_additionl_fields, :boolean)
      field(:hide_cancelation_options, :boolean)
      field(:hide_rescheduling_options, :boolean)
      field(:min_booking_notice, :integer) :: non_neg_integer() | nil
      field(:min_cancellation_notice, :integer) :: non_neg_integer() | nil
      field(:rescheduling_url, :string)

      embeds_one :email_template, EmailTemplate, primary_key: false do
        field(:logo, :string)

        embeds_one :booking_confirmed, BookingConfirmed, primary_key: false do
          field(:title, :string)
          field(:body, :string)
        end
      end
    end

    embeds_one :event_booking, EventBooking
    embeds_many :participants, SchedulingParticipant
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :requires_session_auth, :slug])
    |> cast_embed(:participants)
    |> cast_embed(:event_booking)
    |> cast_embed(:availability, with: &embedded_changeset_availability/2)
    |> cast_embed(:scheduler, with: &embedded_changeset/2)
  end

  @doc false
  def embedded_changeset_availability(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:duration_minutes, :interval_minutes, :round_to])
    |> cast_embed(:availability_rules)
  end
end
