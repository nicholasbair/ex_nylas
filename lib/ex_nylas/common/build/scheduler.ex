defmodule ExNylas.Scheduler.Build do
  @moduledoc """
  Helper module for validating a scheduler configuration before sending it.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder,
    only: [:additional_fields, :available_days_in_future, :cancellation_policy, :cancellation_url,
           :email_template, :hide_additionl_fields, :hide_cancelation_options, :hide_rescheduling_options,
           :min_booking_notice, :min_cancellation_notice, :rescheduling_url]}

  typed_embedded_schema do
    field(:additional_fields, :map)
    field(:available_days_in_future, :integer) :: non_neg_integer()
    field(:cancellation_policy, :string)
    field(:cancellation_url, :string)
    field(:hide_additionl_fields, :boolean)
    field(:hide_cancelation_options, :boolean)
    field(:hide_rescheduling_options, :boolean)
    field(:min_booking_notice, :integer) :: non_neg_integer()
    field(:min_cancellation_notice, :integer) :: non_neg_integer()
    field(:rescheduling_url, :string)

    embeds_one :email_template, EmailTemplate, primary_key: false do
      field(:logo, :string)

      embeds_one :booking_confirmed, BookingConfirmed, primary_key: false do
        field(:title, :string)
        field(:body, :string)
      end
    end
  end

  def changeset(struct, params \\ %{}) do
    cast(struct, params, [
      :additional_fields, :available_days_in_future, :cancellation_policy, :cancellation_url,
      :email_template, :hide_additionl_fields, :hide_cancelation_options, :hide_rescheduling_options,
      :min_booking_notice, :min_cancellation_notice, :rescheduling_url
    ])
  end
end
