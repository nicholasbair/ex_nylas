defmodule ExNylas.Calendars.Availability do
  @moduledoc """
  Interface for Nylas calendar availability.
  """
  use TypedStruct
  use ExNylas,
    struct: __MODULE__,
    include: [:build]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  typedstruct do
    @typedoc "Calendar availability"
    field(:object, String.t())
    field(:timeslots, list())
  end

  typedstruct module: Build do
    @typedoc "A struct representing the calendar availability request payload."
    field(:duration_minutes, non_neg_integer(), enforce: true)
    field(:start_time, non_neg_integer(), enforce: true)
    field(:end_time, non_neg_integer(), enforce: true)
    field(:interval_minutes, non_neg_integer(), enforce: true)
    field(:round_start, boolean())
    field(:emails, list(), enforce: true)
    field(:free_busy, list())
    field(:open_hours, list())
    field(:tentative_busy, boolean())
    field(:round_robin, String.t())
    field(:buffer, non_neg_integer())
    field(:calendars, list())
  end

  @doc """
  Get calendar availability.

  Example
      {:ok, result} = conn |> ExNylas.Calendars.Availability.list(`body`, true)
  """
  def list(%Conn{} = conn, body, consecutive? \\ false) do
    case consecutive? do
      true -> availability_consecutive(conn, body)
      false -> availability(conn, body)
    end
  end

  @doc """
  Get calendar availability.

  Example
      result = conn |> ExNylas.Calendars.Availability.list!(`body`, true)
  """
  def list!(%Conn{} = conn, body, consecutive? \\ false) do
    case list(conn, body, consecutive?) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  defp availability(%Conn{} = conn, body) do
    API.post(
      "#{conn.api_server}/calendars/availability",
      body,
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(Availability)
  end

  defp availability_consecutive(%Conn{} = conn, body) do
    API.post(
      "#{conn.api_server}/calendars/availability/consecutive",
      body,
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(Availability)
  end
end
