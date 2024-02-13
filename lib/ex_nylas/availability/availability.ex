defmodule ExNylas.CalendarAvailability do
  @moduledoc """
  Interface for Nylas calendar availability.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Availability, as: AV

  use ExNylas,
    struct: __MODULE__,
    readable_name: "calendar availability",
    include: [:build]

  @doc """
  Get calendar availability.

  ## Examples

      iex> {:ok, result} = ExNylas.Calendars.Availability.list(conn, body)
  """
  def list(%Conn{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/calendars/availability",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: body
    )
    |> Req.post(conn.options)
    |> API.handle_response(AV)
  end

  @doc """
  Get calendar availability.

  ## Examples

      iex> result = ExNylas.Calendars.Availability.list!(conn, body)
  """
  def list!(%Conn{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
