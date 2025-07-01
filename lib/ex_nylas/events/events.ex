defmodule ExNylas.Events do
  @moduledoc """
  Interface for Nylas events.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/events)
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Event
  alias ExNylas.Response

  use ExNylas,
    object: "events",
    struct: Event,
    readable_name: "event",
    include: [:list, :first, :find, :build, :all, :create, :update, :delete]

  @doc """
  Import events.

  ## Examples

      iex> {:ok, result} = ExNylas.Events.import_events(conn, params)
  """
  @spec import_events(Conn.t(), Keyword.t() | map()) :: {:ok, Response.t()} | {:error, Response.t()}
  def import_events(%Conn{} = conn, params \\ []) do
    Req.new(
      method: :get,
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/events/import",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(),
      params: params
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.request(conn.options)
    |> API.handle_response(Event)
  end

  @doc """
  Import events.

  ## Examples

      iex> result = ExNylas.Events.import_events!(conn, params)
  """
  @spec import_events!(Conn.t(), Keyword.t() | map()) :: Response.t()
  def import_events!(%Conn{} = conn, params \\ []) do
    case import_events(conn, params) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send an RSVP for a given event.

  ## Examples

      iex> {:ok, success} = ExNylas.Events.rsvp(conn, event_id, status, calendar_id)
  """
  @spec rsvp(Conn.t(), String.t(), String.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def rsvp(%Conn{} = conn, event_id, status, calendar_id) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/events/#{event_id}/send-rsvp",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{status: status, calendar_id: calendar_id},
      params: %{calendar_id: calendar_id}
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(Event)
  end

  @doc """
  Send an RSVP for a given event.

  ## Examples

      iex> success = ExNylas.Events.rsvp!(conn, event_id, status, calendar_id)
  """
  @spec rsvp!(Conn.t(), String.t(), String.t(), String.t()) :: Response.t()
  def rsvp!(%Conn{} = conn, event_id, status, calendar_id) do
    case rsvp(conn, event_id, status, calendar_id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
