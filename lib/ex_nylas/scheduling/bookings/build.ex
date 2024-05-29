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
    field :start_time, :integer
    field :end_time, :integer
    field :participants, {:array, :string}

    embeds_one :guest, Guest, primary_key: false do
      @derive {Jason.Encoder, only: [:email, :name]}

      field :email, :string
      field :name, :string
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_time, :end_time, :participants])
    |> validate_required([:start_time, :end_time])
    |> cast_embed(:guest, with: &embedded_changeset/2, required: true)
    |> validate_number(:start_time, less_than_or_equal_to: :end_time)
  end
end
