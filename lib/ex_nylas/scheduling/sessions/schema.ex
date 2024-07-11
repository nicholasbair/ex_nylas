defmodule ExNylas.Scheduling.Session do
  @moduledoc """
  A struct representing a scheduling session.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:session_id, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, [:session_id])
  end
end
