defmodule ExNylas.CalendarFreeBusy do
  @moduledoc """
  Interface for Nylas calendar free/busy.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/calendar)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    ErrorHandler,
    FreeBusy,
    Response,
    ResponseHandler,
    Telemetry
  }

  use ExNylas,
    struct: __MODULE__,
    readable_name: "calendar free/busy",
    include: [:build]

  @doc """
  Get calendar free/busy.

  ## Examples

      iex> {:ok, result} = ExNylas.Calendars.FreeBusy.list(conn, body)
  """
  @spec list(Connection.t(), map()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def list(%Connection{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/calendars/free-busy",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: body
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(FreeBusy)
  end

  @doc """
  Get calendar free/busy.

  ## Examples

      iex> result = ExNylas.Calendars.FreeBusy.list!(conn, body)
  """
  @spec list!(Connection.t(), map()) :: Response.t()
  def list!(%Connection{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end
end
