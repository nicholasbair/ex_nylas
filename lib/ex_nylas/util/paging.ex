defmodule ExNylas.Paging do
  @moduledoc """
  Interface for Nylas paging.
  """

  alias ExNylas.Connection, as: Conn

  @limit 100

  def all(conn, resource, use_cursor_paging, params \\ %{})
  def all(%Conn{} = conn, resource, true = _use_cursor_paging, params), do: page_with_cursor(conn, resource, params)
  def all(%Conn{} = conn, resource, false = _use_cursor_paging, params), do: page_with_offset(conn, resource, params)

  def all!(conn, resource, use_cursor_paging, params \\ %{})
  def all!(%Conn{} = conn, resource, true = _use_cursor_paging, params) do
    case page_with_cursor(conn, resource, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  def all!(%Conn{} = conn, resource, false = _use_cursor_paging, params) do
    case page_with_offset(conn, resource, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  defp page_with_cursor(%Conn{} = conn, resource, query, next_cursor \\ nil, acc \\ []) do
    query = Map.put(query, :page_token, next_cursor)

    case apply(resource, :list, [conn, query]) do
      {:ok, res} ->
        new = acc ++ Map.get(res, :data, [])

        case res.next_cursor do
          nil -> {:ok, new}
          _ -> page_with_cursor(conn, resource, query, res.next_cursor, new)
        end

      err ->
        err
    end
  end

  defp page_with_offset(%Conn{} = conn, resource, query, offset \\ 0, acc \\ []) do
    query =
      query
      |> Map.put_new(:limit, @limit)
      |> Map.put(:offset, offset)

    case apply(resource, :list, [conn, query]) do
      {:ok, data} ->
        new = acc ++ data
        limit = Map.get(query, :limit)

        case length(data) == limit do
          true -> page_with_offset(conn, resource, query, offset + limit, new)
          false -> {:ok, new}
        end

      err ->
        err
    end
  end
end
