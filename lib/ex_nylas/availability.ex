defmodule ExNylas.Calendars.Availability do
  @moduledoc """
  Interface for Nylas calendar availability.
  """

  use ExNylas,
    struct: ExNylas.Model.Calendar.Availability,
    include: [:build]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Get calendar availability.

  Example
      {:ok, result} = conn |> ExNylas.Calendars.Availability.list(`body`)
  """
  def list(%Conn{} = conn, body) do
    API.post(
      "#{conn.api_server}/v3/calendars/availability",
      body,
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Model.Calendar.Availability.as_struct())
  end

  @doc """
  Get calendar availability.

  Example
      result = conn |> ExNylas.Calendars.Availability.list!(`body`)
  """
  def list!(%Conn{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
