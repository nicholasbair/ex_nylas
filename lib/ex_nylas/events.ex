defmodule ExNylas.Events do
  @moduledoc """
  Interface for Nylas event.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Model.Event

  use ExNylas,
    object: "events",
    struct: ExNylas.Model.Event,
    include: [:list, :first, :find, :build, :all, :create, :update, :delete]

  @doc """
  Send an RSVP for a given event

  Example
      {:ok, success} = conn |> ExNylas.Events.rsvp(`event_id`, `calendar_id`, `status`)
  """
  def rsvp(%Conn{} = conn, event_id, calendar_id, status) do
    API.post(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/events/#{event_id}/send-rsvp?calendar_id=#{calendar_id}",
      %{status: status},
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(Event)
  end

  @doc """
  Send an RSVP for a given event

  Example
      success = conn |> ExNylas.Events.rsvp!(`event_id`, `calendar_id`, `status`)
  """
  def rsvp!(%Conn{} = conn, event_id, calendar_id, status) do
    case rsvp(conn, event_id, calendar_id, status) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
