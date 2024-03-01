defmodule ExNylas.CalendarFreeBusy do
  @moduledoc """
  Interface for Nylas calendar free/busy.
  """

  alias ExNylas.API
  alias ExNylas.Common.Response
  alias ExNylas.Connection, as: Conn
  alias ExNylas.FreeBusy, as: FB

  use ExNylas,
    struct: __MODULE__,
    readable_name: "calendar free/busy",
    include: [:build]

  @doc """
  Get calendar free/busy.

  ## Examples

      iex> {:ok, result} = ExNylas.Calendars.FreeBusy.list(conn, body)
  """
  @spec list(Conn.t(), map()) :: {:ok, Response.t()} | {:error, Response.t()}
  def list(%Conn{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/calendars/free-busy",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: body
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(FB)
  end

  @doc """
  Get calendar free/busy.

  ## Examples

      iex> result = ExNylas.Calendars.FreeBusy.list!(conn, body)
  """
  @spec list!(Conn.t(), map()) :: Response.t()
  def list!(%Conn{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
