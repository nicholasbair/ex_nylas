defmodule ExNylas.Buffer do
  @moduledoc """
  A struct for buffer.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:after, :integer) :: non_neg_integer() | nil
    field(:before, :integer) :: non_neg_integer() | nil
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:before, :after])
  end
end
