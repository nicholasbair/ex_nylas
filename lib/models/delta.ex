defmodule ExNylas.Delta do
  @moduledoc """
  A struct representing a delta & interface for Nylas delta.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A delta/cursor"
    field :cursor, String.t()
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  @doc """
  Get the latest delta cursor.

  Example
      {:ok, result} = conn |> ExNylas.Delta.latest_cursor()
  """
  def latest_cursor(%Conn{} = conn) do
    res =
      API.post(
        "#{conn.api_server}/latest_cursor",
        API.header_bearer(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.Delta)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
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
      "#{conn.api_server}/streaming?cursor=#{cursor}",
      API.header_bearer(conn),
      [
        stream_to: stream_to,
        timeout: :infinity
      ]
    )
  end

end
