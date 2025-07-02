defmodule ExNylas.CalendarAvailability do
  @moduledoc """
  Interface for Nylas calendar availability.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/calendar)
  """

  alias ExNylas.{API, Auth, ResponseHandler, Telemetry}
  alias ExNylas.Availability, as: AV
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Response

  use ExNylas,
    struct: __MODULE__,
    readable_name: "calendar availability",
    include: [:build]

  @doc """
  Get calendar availability.

  ## Examples

      iex> {:ok, result} = ExNylas.CalendarAvailability.list(conn, body)
  """
  @spec list(Conn.t(), map()) :: {:ok, Response.t()} | {:error, Response.t()}
  def list(%Conn{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/calendars/availability",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: body
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(AV)
  end

  @doc """
  Get calendar availability.

  ## Examples

      iex> result = ExNylas.CalendarAvailability.list!(conn, body)
  """
  @spec list!(Conn.t(), map()) :: Response.t()
  def list!(%Conn{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
