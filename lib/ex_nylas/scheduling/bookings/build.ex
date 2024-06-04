defmodule ExNylas.Scheduling.Booking.Build do
  @moduledoc """
  Helper module for validating a scheduling booking before sending it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @derive {Jason.Encoder, only: [:start_time, :end_time, :participants, :guest]}
  @primary_key false

  typed_embedded_schema do
    field(:end_time, :integer) :: non_neg_integer()
    field(:participants, {:array, :string})
    field(:start_time, :integer) :: non_neg_integer()

    embeds_one :guest, Guest, primary_key: false do
      @derive {Jason.Encoder, only: [:email, :name]}

      field(:email, :string, null: false)
      field(:name, :string, null: false)
    end

    embeds_many :additional_guests, AdditionalGuests, primary_key: false do
      @derive {Jason.Encoder, only: [:email, :name]}

      field(:email, :string, null: false)
      field(:name, :string, null: false)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_time, :end_time, :participants])
    |> validate_required([:start_time, :end_time])
    |> cast_embed(:guest, with: &embedded_changeset/2, required: true)
    |> cast_embed(:additional_guests, with: &embedded_changeset/2)
    |> validate_number(:start_time, less_than_or_equal_to: :end_time)
  end
end
