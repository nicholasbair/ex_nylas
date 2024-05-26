defmodule ExNylas.Scheduling.Session.Build do
  @moduledoc """
  Helper module for validating a scheduling session before sending it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          configuration_id: String.t(),
          time_to_live: non_neg_integer()
        }

  @derive {Jason.Encoder, only: [:configuration_id, :time_to_live]}
  @primary_key false

  embedded_schema do
    field :configuration_id, :string
    field :time_to_live, :integer, default: 5
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:configuration_id, :time_to_live])
    |> validate_required([:configuration_id])
    |> validate_number(:time_to_live, less_than_or_equal_to: 30)
  end
end
