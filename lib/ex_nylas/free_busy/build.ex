defmodule ExNylas.CalendarFreeBusy.Build do
  @moduledoc """
  Helper module for validating the free/busy request.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/calendar)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:emails, :start_time, :end_time]}
  @primary_key false

  typed_embedded_schema do
    field(:emails, {:array, :string}, null: false)
    field(:end_time, :integer, null: false) :: non_neg_integer()
    field(:start_time, :integer, null: false) :: non_neg_integer()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:emails, :start_time, :end_time])
    |> validate_required([:emails, :start_time, :end_time])
  end
end
