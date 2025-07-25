defmodule ExNylas.Buffer.Build do
  @moduledoc """
  A struct for buffer.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:before, :after]}

  typed_embedded_schema do
    field(:after, :integer) :: non_neg_integer()
    field(:before, :integer) :: non_neg_integer()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:before, :after])
    |> validate_number(:before, greater_than_or_equal: 0)
    |> validate_number(:after, greater_than_or_equal: 0)
  end
end
