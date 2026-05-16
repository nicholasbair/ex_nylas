defmodule ExNylas.Paging.Offset do
  @moduledoc false

  alias ExNylas.{
    Connection,
    Paging.Helpers,
    Paging.Options,
    Response
  }

  import ExNylas.Util

  @limit 50

  @spec all(
          Connection.t(),
          (Connection.t(), Keyword.t() | map() ->
             {:ok, Response.t()} | {:error, ExNylas.error_reason()}),
          Keyword.t() | map()
        ) ::
          {:ok, [struct()]} | {:error, ExNylas.error_reason()}
  def all(conn, list_function, opts \\ []) do
    page_with_offset(conn, list_function, Options.from_opts(opts))
  end

  defp page_with_offset(%Connection{} = conn, list_function, opts, offset \\ 0, acc \\ []) do
    %{query: query, delay: delay, send_to: send_to, with_metadata: with_metadata} = opts

    query =
      query
      |> indifferent_put_new(:limit, @limit)
      |> put_in([:offset], offset)

    case list_function.(conn, query) do
      {:ok, res} ->
        data = Map.get(res, :data, [])
        new = Helpers.send_or_accumulate(send_to, with_metadata, acc, data)
        limit = indifferent_get(query, :limit)

        case length(data) == limit do
          true ->
            Helpers.maybe_delay(delay)
            page_with_offset(conn, list_function, opts, offset + limit, new)

          false ->
            {:ok, new}
        end

      err ->
        err
    end
  end
end
