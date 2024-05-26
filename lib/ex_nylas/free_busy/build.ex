defmodule ExNylas.CalendarFreeBusy.Build do
  @moduledoc """
  Helper module for validating the free/busy request.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          emails: [String.t()],
          start_time: non_neg_integer(),
          end_time: non_neg_integer()
        }

  @derive {Jason.Encoder, only: [:emails, :start_time, :end_time]}
  @primary_key false

  embedded_schema do
    field :emails, {:array, :string}
    field :start_time, :integer
    field :end_time, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:emails, :start_time, :end_time])
    |> validate_required([:emails, :start_time, :end_time])
  end
end
