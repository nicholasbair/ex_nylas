defmodule ExNylas.Paging.Cursor do
  @moduledoc false

  alias ExNylas.Connection, as: Conn
  alias ExNylas.Response
  alias ExNylas.Paging.Options
  alias ExNylas.Paging.Helpers

  @spec all(Conn.t(), (Conn.t(), Keyword.t() | map() -> {:ok, Response.t()} | {:error, Response.t()}), Keyword.t() | map()) :: {:ok, [struct()]} | {:error, Response.t()}
  def all(conn, list_function, opts \\ []) do
    page_with_cursor(conn, list_function, Options.from_opts(opts))
  end



  defp page_with_cursor(%Conn{} = conn, list_function, opts, next_cursor \\ nil, acc \\ []) do
    %{query: query, delay: delay, send_to: send_to, with_metadata: with_metadata} = opts
    query = put_in(query, [:page_token], next_cursor)

    case list_function.(conn, query) do
      {:ok, res} ->
        new = Helpers.send_or_accumulate(send_to, with_metadata, acc, Map.get(res, :data, []))

        case res.next_cursor do
          nil ->
            {:ok, new}

          _ ->
            Helpers.maybe_delay(delay)
            page_with_cursor(conn, list_function, opts, res.next_cursor, new)
        end

      err ->
        err
    end
  end
end
