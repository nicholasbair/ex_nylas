defmodule ExNylas.Paging do
  @moduledoc """
  Interface for Nylas paging.
  """

  alias ExNylas.Connection, as: Conn
  alias ExNylas.Common.Response

  import ExNylas.Util, only: [indifferent_get: 3, indifferent_put_new: 3]

  @limit 50

  @spec all(Conn.t(), atom(), boolean(), Keyword.t() | map()) :: {:ok, [struct()]} | {:error, Response.t()}
  def all(conn, resource, use_cursor_paging, opts \\ [])
  def all(%Conn{} = conn, resource, true = _use_cursor_paging, opts) do
    {query, delay, send_to, with_metadata} = unwrap_opts(opts)
    page_with_cursor(conn, resource, query, delay, send_to, with_metadata)
  end

  def all(%Conn{} = conn, resource, false = _use_cursor_paging, opts) do
    {query, delay, send_to, with_metadata} = unwrap_opts(opts)
    page_with_offset(conn, resource, query, delay, send_to, with_metadata)
  end

  @spec all!(Conn.t(), atom(), boolean(), Keyword.t() | map()) :: [struct()]
  def all!(conn, resource, use_cursor_paging, opts \\ [])
  def all!(%Conn{} = conn, resource, true = _use_cursor_paging, opts) do
    {query, delay, send_to, with_metadata} = unwrap_opts(opts)

    case page_with_cursor(conn, resource, query, delay, send_to, with_metadata) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  def all!(%Conn{} = conn, resource, false = _use_cursor_paging, opts) do
    {query, delay, send_to, with_metadata} = unwrap_opts(opts)

    case page_with_offset(conn, resource, query, delay, send_to, with_metadata) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  defp page_with_cursor(%Conn{} = conn, resource, query, delay, send_to, with_metadata, next_cursor \\ nil, acc \\ []) do
    query = put_in(query, [:page_token], next_cursor)

    case apply(resource, :list, [conn, query]) do
      {:ok, res} ->
        new = send_or_accumulate(send_to, with_metadata, acc, Map.get(res, :data, []))

        case res.next_cursor do
          nil ->
            {:ok, new}

          _ ->
            maybe_delay(delay)
            page_with_cursor(conn, resource, query, delay, send_to, with_metadata, res.next_cursor, new)
        end

      err ->
        err
    end
  end

  defp page_with_offset(%Conn{} = conn, resource, query, delay, send_to, with_metadata, offset \\ 0, acc \\ []) do
    query =
      query
      |> indifferent_put_new(:limit, @limit)
      |> put_in([:offset], offset)

    case apply(resource, :list, [conn, query]) do
      {:ok, res} ->
        data = Map.get(res, :data, [])
        new = send_or_accumulate(send_to, with_metadata, acc, data)
        limit = Map.get(query, :limit)

        case length(data) == limit do
          true ->
            maybe_delay(delay)
            page_with_offset(conn, resource, query, delay, send_to, with_metadata, offset + limit, new)

          false ->
            {:ok, new}
        end

      err ->
        err
    end
  end

  defp unwrap_opts(opts) do
    {
      indifferent_get(opts, :query, []),
      indifferent_get(opts, :delay, 0),
      indifferent_get(opts, :send_to, nil),
      indifferent_get(opts, :with_metadata, nil),
    }
  end

  defp maybe_delay(delay) when delay <= 0, do: :ok
  defp maybe_delay(delay) when delay > 0, do: :timer.sleep(delay)

  defp send_or_accumulate(nil, _, acc, data), do: acc ++ data

  defp send_or_accumulate(send_to, nil, acc, data) do
    send_to.(data)
    acc
  end

  defp send_or_accumulate(send_to, with_metadata, acc, data) do
    send_to.({with_metadata, data})
    acc
  end
end
