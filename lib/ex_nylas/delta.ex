defmodule ExNylas.Delta do
  @moduledoc """
  A struct representing a delta & interface for Nylas delta.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A delta/cursor"
    field(:cursor, String.t())
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Get the latest delta cursor.

  Example
      {:ok, result} = conn |> ExNylas.Delta.latest_cursor()
  """
  def latest_cursor(%Conn{} = conn) do
    API.post(
      "#{conn.api_server}/delta/latest_cursor",
      %{},
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(__MODULE__)
  end

  @doc """
  Get the latest delta cursor.

  Example
      result = conn |> ExNylas.Delta.latest_cursor!()
  """
  def latest_cursor!(%Conn{} = conn) do
    case latest_cursor(conn) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Start a delta stream, where `stream_to` is the name of a GenServer that implements `handle_info/2`.

  Example
      ExNylas.Delta.start_stream(conn, `cursor`, `stream_to`)
  """
  def start_stream(%Conn{} = conn, cursor, stream_to) do
    API.get(
      "#{conn.api_server}/delta/streaming?cursor=#{cursor}",
      API.header_bearer(conn),
      stream_to: stream_to,
      timeout: :infinity
    )
  end
end
