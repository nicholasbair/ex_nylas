defmodule ExNylas.CalendarAvailability do
  @moduledoc """
  Interface for Nylas calendar availability.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/calendar)
  """

  alias ExNylas.{
    API,
    Auth,
    Availability,
    Connection,
    DecodeError,
    ErrorHandler,
    Response,
    ResponseHandler,
    Telemetry,
    TransportError
  }

  use ExNylas,
    struct: __MODULE__,
    readable_name: "calendar availability",
    include: [:build]

  @doc """
  Get calendar availability.

  ## Examples

      iex> {:ok, result} = ExNylas.CalendarAvailability.list(conn, body)
  """
  @spec list(Connection.t(), map()) ::
          {:ok, Response.t()}
          | {:error,
               Response.t()
               | TransportError.t()
               | DecodeError.t()}
  def list(%Connection{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/calendars/availability",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: body
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(Availability)
  end

  @doc """
  Get calendar availability.

  ## Examples

      iex> result = ExNylas.CalendarAvailability.list!(conn, body)
  """
  @spec list!(Connection.t(), map()) :: Response.t()
  def list!(%Connection{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end
end
