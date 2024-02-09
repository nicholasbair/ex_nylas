defmodule ExNylas.Schema.Util do

  import Ecto.Changeset

  def embedded_changeset(struct, params) do
    keys =
      struct
      |> Map.keys()
      |> Enum.reject(& &1 in [:__meta__, :__struct__])

    struct
    |> cast(params, keys)
  end
end
