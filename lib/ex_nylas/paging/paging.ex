defmodule ExNylas.Paging do
  @moduledoc false

  alias ExNylas.{
    Connection,
    Paging.Cursor,
    Paging.Offset,
    Response
  }

  @spec all(
          Connection.t(),
          (Connection.t(), Keyword.t() | map() -> {:ok, Response.t()} | {:error, Response.t()}),
          boolean(),
          Keyword.t() | map()
        ) :: {:ok, [struct()]} | {:error, Response.t()}
  def all(conn, list_function, use_cursor_paging, opts \\ [])
  def all(conn, list_function, true = _use_cursor_paging, opts) do
    Cursor.all(conn, list_function, opts)
  end

  def all(conn, list_function, false = _use_cursor_paging, opts) do
    Offset.all(conn, list_function, opts)
  end

  @spec all!(
          Connection.t(),
          (Connection.t(), Keyword.t() | map() -> {:ok, Response.t()} | {:error, Response.t()}),
          boolean(),
          Keyword.t() | map()
        ) :: [struct()]
  def all!(conn, list_function, use_cursor_paging, opts \\ [])
  def all!(conn, list_function, true = _use_cursor_paging, opts) do
    case Cursor.all(conn, list_function, opts) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  def all!(conn, list_function, false = _use_cursor_paging, opts) do
    case Offset.all(conn, list_function, opts) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
