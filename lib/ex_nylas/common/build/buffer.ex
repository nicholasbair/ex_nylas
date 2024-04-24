defmodule ExNylas.Common.Build.Buffer do
  @moduledoc """
  A struct for buffer.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:before, :after]}

  embedded_schema do
    field :before, :integer
    field :after, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:before, :after])
    |> validate_number(:before, greater_than_or_equal: 0)
    |> validate_number(:after, greater_than_or_equal: 0)
  end
end
