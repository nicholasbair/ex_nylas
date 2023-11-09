defmodule ExNylas.Events do
  @moduledoc """
  Interface for Nylas event.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Model.Event

  use ExNylas,
    object: "events",
    struct: Event,
    readable_name: "event",
    include: [:list, :first, :find, :build, :all, :create, :update, :delete]

  @doc """
  Send an RSVP for a given event

  Example
      {:ok, success} = conn |> ExNylas.Events.rsvp(`event_id`, `status`, `%{calendar_id: calendar_id}`)
  """
  def rsvp(%Conn{} = conn, event_id, status, %{calendar_id: _calendar_id} = params) do
    API.post(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/events/#{event_id}/send-rsvp",
      %{status: status},
      API.header_bearer(conn) ++ ["content-type": "application/json"],
      [
        timeout: conn.timeout,
        recv_timeout: conn.recv_timeout,
        params: params
      ]
    )
    |> API.handle_response(Event.as_struct())
  end

  @doc """
  Send an RSVP for a given event

  Example
      success = conn |> ExNylas.Events.rsvp!(`event_id`, `status`, `%{calendar_id: calendar_id}`)
  """
  def rsvp!(%Conn{} = conn, event_id, status, %{calendar_id: _calendar_id} = params) do
    case rsvp(conn, event_id, status, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
