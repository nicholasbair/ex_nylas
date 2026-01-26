defmodule ExNylas.Paging.Cursor do
  @moduledoc false

  alias ExNylas.{
    Connection,
    Paging.Helpers,
    Paging.Options,
    Response
  }

  @spec all(
          Connection.t(),
          (Connection.t(), Keyword.t() | map() ->
             {:ok, Response.t()}
             | {:error, ExNylas.APIError.t() | ExNylas.TransportError.t() | ExNylas.DecodeError.t()}),
          Keyword.t() | map()
        ) ::
          {:ok, [struct()]}
          | {:error, ExNylas.APIError.t() | ExNylas.TransportError.t() | ExNylas.DecodeError.t()}
  def all(conn, list_function, opts \\ []) do
    page_with_cursor(conn, list_function, Options.from_opts(opts))
  end

  @spec page_with_cursor(
          Connection.t(),
          (Connection.t(), Keyword.t() | map() ->
             {:ok, Response.t()}
             | {:error, ExNylas.APIError.t() | ExNylas.TransportError.t() | ExNylas.DecodeError.t()}),
          Keyword.t() | map(),
          any() | nil,
          [any()]
        ) ::
          {:ok, [any()]}
          | {:error, ExNylas.APIError.t() | ExNylas.TransportError.t() | ExNylas.DecodeError.t()}
  defp page_with_cursor(%Connection{} = conn, list_function, opts, next_cursor \\ nil, acc \\ []) do
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
