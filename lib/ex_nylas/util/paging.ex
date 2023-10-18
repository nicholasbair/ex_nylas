defmodule ExNylas.Paging do
  @moduledoc """
  Interface for Nylas paging.
  """

  alias ExNylas.Connection, as: Conn

  def all(%Conn{} = conn, resource, params \\ %{}), do: page(conn, resource, params)

  def all!(%Conn{} = conn, resource, params \\ %{}) do
    case page(conn, resource, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  defp page(%Conn{} = conn, resource, query, next_cursor \\ nil, acc \\ []) do
    query = Map.put(query, :page_token, next_cursor)

    case apply(resource, :list, [conn, query]) do
      {:ok, res} ->
        new = acc ++ Map.get(res, :data, [])

        case res.next_cursor do
          nil -> {:ok, new}
          _ -> page(conn, resource, query, res.next_cursor, new)
        end

      err ->
        err
    end
  end
end
