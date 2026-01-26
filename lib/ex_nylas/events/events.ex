defmodule ExNylas.Events do
  @moduledoc """
  Interface for Nylas events.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/events)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    Event,
    Response,
    ResponseHandler,
    Telemetry
  }

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
  @spec import_events(Connection.t(), Keyword.t() | map()) ::
          {:ok, Response.t()}
          | {:error,
               ExNylas.APIError.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()}
  def import_events(%Connection{} = conn, params \\ []) do
    Req.new(
      method: :get,
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/events/import",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(),
      params: params
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.request(conn.options)
    |> ResponseHandler.handle_response(Event)
  end

  @doc """
  Import events.

  ## Examples

      iex> result = ExNylas.Events.import_events!(conn, params)
  """
  @spec import_events!(Connection.t(), Keyword.t() | map()) :: Response.t()
  def import_events!(%Connection{} = conn, params \\ []) do
    case import_events(conn, params) do
      {:ok, body} -> body
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Send an RSVP for a given event.

  ## Examples

      iex> {:ok, success} = ExNylas.Events.rsvp(conn, event_id, status, calendar_id)
  """
  @spec rsvp(Connection.t(), String.t(), String.t(), String.t()) ::
          {:ok, Response.t()}
          | {:error,
               ExNylas.APIError.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()}
  def rsvp(%Connection{} = conn, event_id, status, calendar_id) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/events/#{event_id}/send-rsvp",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{status: status, calendar_id: calendar_id},
      params: %{calendar_id: calendar_id}
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(Event)
  end

  @doc """
  Send an RSVP for a given event.

  ## Examples

      iex> success = ExNylas.Events.rsvp!(conn, event_id, status, calendar_id)
  """
  @spec rsvp!(Connection.t(), String.t(), String.t(), String.t()) :: Response.t()
  def rsvp!(%Connection{} = conn, event_id, status, calendar_id) do
    case rsvp(conn, event_id, status, calendar_id) do
      {:ok, res} -> res
      {:error, exception} -> raise exception
    end
  end
end
