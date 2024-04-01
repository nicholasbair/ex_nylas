defmodule ExNylas.Common.Buffer do
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
  end
end
