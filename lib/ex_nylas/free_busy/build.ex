defmodule ExNylas.CalendarFreeBusy.Build do
  @moduledoc """
  Helper module for validating the free/busy request.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:emails, :start_time, :end_time]}
  @primary_key false

  typed_embedded_schema do
    field :emails, {:array, :string}
    field :start_time, :integer
    field :end_time, :integer
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:emails, :start_time, :end_time])
    |> validate_required([:emails, :start_time, :end_time])
  end
end
