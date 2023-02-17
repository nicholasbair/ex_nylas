defmodule ExNylas.Paging do
  alias ExNylas.Connection, as: Conn

  @limit 100

  def all(%Conn{} = conn, resource, params \\ %{}), do: page(conn, resource, params)

  def all!(%Conn{} = conn, resource, params \\ %{}) do
    case page(conn, resource, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  defp page(%Conn{} = conn, resource, query, offset \\ 0, acc \\ []) do
    query =
      query
      |> Map.put(:limit, @limit)
      |> Map.put(:offset, offset)

    case apply(resource, :list, [conn, query]) do
      {:ok, data} ->
        new = acc ++ data

        case length(data) == @limit do
          true -> page(conn, resource, query, offset + @limit, new)
          false -> {:ok, new}
        end

      err ->
        err
    end
  end
end
