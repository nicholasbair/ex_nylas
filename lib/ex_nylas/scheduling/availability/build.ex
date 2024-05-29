defmodule ExNylas.Scheduling.Availability.Build do
  @moduledoc """
  Helper module for building scheduling availability objects.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:start_time, :end_time]}
  @primary_key false

  typed_embedded_schema do
    field :start_time, :integer
    field :end_time, :integer
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_time, :end_time])
    |> validate_required([:start_time, :end_time])
    |> validate_number(:start_time, less_than_or_equal_to: :end_time)
  end
end
