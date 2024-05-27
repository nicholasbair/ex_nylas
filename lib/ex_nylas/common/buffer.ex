defmodule ExNylas.Common.Buffer do
  @moduledoc """
  A struct for buffer.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field :before, :integer
    field :after, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:before, :after])
  end
end
