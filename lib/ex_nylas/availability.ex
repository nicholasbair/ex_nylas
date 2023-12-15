defmodule ExNylas.Calendars.Availability do
  @moduledoc """
  Interface for Nylas calendar availability.
  """

  use ExNylas,
    struct: ExNylas.Model.Calendar.Availability,
    readable_name: "calendar availability",
    include: [:build]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Get calendar availability.

  Example
      {:ok, result} = ExNylas.Calendars.Availability.list(conn, `body`)
  """
  def list(%Conn{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/calendars/availability",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      body: API.process_request_body(body),
      decode_body: false
    )
    |> Req.post(conn.options)
    |> API.handle_response(ExNylas.Model.Calendar.Availability.as_struct())
  end

  @doc """
  Get calendar availability.

  Example
      result = ExNylas.Calendars.Availability.list!(conn, `body`)
  """
  def list!(%Conn{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
