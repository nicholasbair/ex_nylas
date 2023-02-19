defmodule ExNylas.Event do
  @moduledoc """
  A struct representing a event.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A event"
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
    field(:calendar_id, String.t())
    field(:message_id, String.t())
    field(:title, String.t())
    field(:description, String.t())
    field(:owner, String.t())
    field(:participants, list())
    field(:read_only, boolean())
    field(:location, String.t())
    field(:when, map())
    field(:busy, boolean())
    field(:status, String.t())
    field(:ical_uid, String.t())
    field(:master_event_id, String.t())
    field(:original_start_time, non_neg_integer())
    field(:updated_at, non_neg_integer())
    field(:conferencing, map())
    field(:recurrence, map())
    field(:metadata, map())
    field(:notifications, list())
    field(:organizer_email, String.t())
    field(:organizer_name, String.t())
    field(:visibility, String.t())
    field(:hide_participants, boolean())
  end

  typedstruct module: Build do
    @typedoc "A struct representing the create event request payload."
    field(:calendar_id, String.t(), enforce: true)
    field(:when, map(), enforce: true)
    field(:title, String.t())
    field(:description, String.t())
    field(:location, String.t())
    field(:participants, list())
    field(:busy, boolean())
    field(:recurrance, map())
    field(:visibility, String.t())
    field(:conferencing, map())
    field(:reminder_minutes, String.t())
    field(:reminder_method, String.t())
    field(:metadata, map())
    field(:notifications, list())
    field(:hide_participants, boolean())
  end
end

defmodule ExNylas.Events do
  @moduledoc """
  Interface for Nylas event.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Event

  use ExNylas,
    object: "events",
    struct: ExNylas.Event,
    include: [:list, :first, :find, :build, :all]

  @doc """
  Create/update for an event

  Example
      {:ok, binary} = conn |> ExNylas.Events.save(`body`)
  """
  def save(%Conn{} = conn, body, notify_participants \\ true) do
    {method, url} =
      case body.id do
        nil -> {:post, "#{conn.api_server}/events"}
        _ -> {:put, "#{conn.api_server}/events/#{body.id}"}
      end

    apply(
      API,
      method,
      [
        url,
        body,
        API.header_bearer(conn) ++ ["content-type": "application/json"],
        [params: %{notify_participants: notify_participants}]
      ]
    )
    |> API.handle_response(Event)
  end

  @doc """
  Create/update for an event

  Example
      binary = conn |> ExNylas.Events.save!(`body`)
  """
  def save!(%Conn{} = conn, body, notify_participants \\ true) do
    case save(conn, body, notify_participants) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send an RSVP for a given event

  Example
      {:ok, binary} = conn |> ExNylas.Events.rsvp(`event_id`, `status`, `account_id`)
  """
  def rsvp(%Conn{} = conn, event_id, status, account_id) do
    API.post(
      "#{conn.api_server}/send-rsvp",
      %{event_id: event_id, status: status, account_id: account_id},
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(Event)
  end

  @doc """
  Send an RSVP for a given event

  Example
      binary = conn |> ExNylas.Events.rsvp!(`event_id`, `status`, `account_id`)
  """
  def rsvp!(%Conn{} = conn, event_id, status, account_id) do
    case rsvp(conn, event_id, status, account_id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
