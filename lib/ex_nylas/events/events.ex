defmodule ExNylas.Events do
  @moduledoc """
  Interface for Nylas event.
  """

  alias ExNylas.API
  alias ExNylas.Common.Response
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Event

  use ExNylas,
    object: "events",
    struct: Event,
    readable_name: "event",
    include: [:list, :first, :find, :build, :all, :create, :update, :delete]

  @doc """
  Send an RSVP for a given event

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
  Send an RSVP for a given event

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
