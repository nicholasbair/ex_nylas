defmodule ExNylas.Schema.Util do
  @moduledoc """
  Utility functions for schemas.
  """

  import Ecto.Changeset

  @spec embedded_changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def embedded_changeset(struct, params) do
    keys =
      struct
      |> Map.keys()
      |> Enum.reject(& &1 in [:__meta__, :__struct__])

    struct
    |> cast(params, keys)
  end
end
