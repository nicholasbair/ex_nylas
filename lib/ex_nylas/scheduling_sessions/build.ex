defmodule ExNylas.SchedulingSession.Build do
  @moduledoc """
  Helper module for validating a scheduling session before sending it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:config_id, :time_to_live]}
  @primary_key false

  embedded_schema do
    field :config_id, :string
    field :time_to_live, :integer, default: 5
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:config_id, :time_to_live])
    |> validate_required([:config_id])
    |> validate_number(:time_to_live, less_than_or_equal_to: 30)
  end
end
