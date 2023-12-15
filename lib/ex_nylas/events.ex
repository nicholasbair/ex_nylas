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
      {:ok, success} = ExNylas.Events.rsvp(conn, `event_id`, `status`, `calendar_id`)
  """
  def rsvp(%Conn{} = conn, event_id, status, calendar_id) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/events/#{event_id}/send-rsvp",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: %{status: status, calendar_id: calendar_id},
      decode_body: false,
      params: %{calendar_id: calendar_id}
    )
    |> Req.post(conn.options)
    |> API.handle_response(Event.as_struct())
  end

  @doc """
  Send an RSVP for a given event

  Example
      success = ExNylas.Events.rsvp!(conn, `event_id`, `status`, `calendar_id`)
  """
  def rsvp!(%Conn{} = conn, event_id, status, calendar_id) do
    case rsvp(conn, event_id, status, calendar_id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
