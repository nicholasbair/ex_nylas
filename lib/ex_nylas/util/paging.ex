defmodule ExNylas.Paging do
  @moduledoc """
  Interface for Nylas paging.
  """

  alias ExNylas.Connection, as: Conn

  @limit 50

  def all(conn, resource, use_cursor_paging, params \\ [])
  def all(%Conn{} = conn, resource, true = _use_cursor_paging, params), do: page_with_cursor(conn, resource, params)
  def all(%Conn{} = conn, resource, false = _use_cursor_paging, params), do: page_with_offset(conn, resource, params)

  def all!(conn, resource, use_cursor_paging, params \\ [])
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
    query = put_in(query, [:page_token], next_cursor)

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
      |> indifferent_put_new(:limit, @limit)
      |> put_in([:offset], offset)

    case apply(resource, :list, [conn, query]) do
      {:ok, res} ->
        data = Map.get(res, :data, [])
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

  defp indifferent_put_new(map, key, value) when is_map(map) do
    Map.put_new(map, key, value)
  end

  defp indifferent_put_new(keyword, key, value) when is_list(keyword) do
    Keyword.put_new(keyword, key, value)
  end
end
