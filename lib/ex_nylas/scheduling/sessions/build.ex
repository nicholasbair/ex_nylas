defmodule ExNylas.Scheduling.Session.Build do
  @moduledoc """
  Helper module for validating a scheduling session before sending it.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/scheduler/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:configuration_id, :slug, :time_to_live]}
  @primary_key false

  typed_embedded_schema do
    field(:configuration_id, :string)
    field(:slug, :string)
    field(:time_to_live, :integer, default: 5) :: non_neg_integer()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:configuration_id, :slug, :time_to_live])
    |> validate_number(:time_to_live, less_than_or_equal_to: 30)
  end
end
