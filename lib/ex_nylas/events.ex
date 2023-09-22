defmodule ExNylas.Event do
  @moduledoc """
  A struct representing a event.
  """

  defstruct [
    :busy,
    :calendar_id,
    :conferencing,
    :created_at,
    :description,
    :hide_participants,
    :grant_id,
    :html_link,
    :ical_uid,
    :id,
    :location,
    :master_event_id,
    :metadata,
    :object,
    :organizer,
    :participants,
    :read_only,
    :reminders,
    :recurrence,
    :status,
    :title,
    :updated_at,
    :visibility,
    :when,
  ]

  @typedoc "A event"
  @type t :: %__MODULE__{
    busy: boolean(),
    calendar_id: String.t(),
    conferencing: ExNylas.Event.Conferencing.t(),
    created_at: non_neg_integer(),
    description: String.t(),
    hide_participants: boolean(),
    grant_id: String.t(),
    html_link: String.t(),
    ical_uid: String.t(),
    id: String.t(),
    location: String.t(),
    master_event_id: String.t(),
    metadata: map(),
    object: String.t(),
    organizer: ExNylas.Event.Organizer.t(),
    participants: [ExNylas.Event.Participant.t()],
    read_only: boolean(),
    reminders: [ExNylas.Event.Reminder.t()],
    recurrence: [String.t()],
    status: String.t(),
    title: String.t(),
    updated_at: non_neg_integer(),
    visibility: String.t(),
    when: ExNylas.Event.When.t(),
  }

  defmodule Reminder do
    defstruct [
      :overrides,
      :use_default,
    ]

    @type t :: %__MODULE__{
      overrides: [map()],
      use_default: boolean(),
    }
  end

  defmodule Organizer do
    defstruct [
      :email,
      :name,
    ]

    @type t :: %__MODULE__{
      email: String.t(),
      name: String.t(),
    }
  end

  defmodule Participant do
    @enforce_keys [:email]
    defstruct [
      :name,
      :email,
      :status,
      :comment,
      :phone_number,
    ]

    @type t :: %__MODULE__{
      name: String.t(),
      email: String.t(),
      status: String.t(),
      comment: String.t(),
      phone_number: String.t(),
    }
  end

  defmodule When do
    defstruct [
      :start_time,
      :end_time,
      :start_timezone,
      :end_timezone,
      :object,
      :time,
      :timezone,
      :start_date,
      :end_date,
      :date,
    ]

    @type t :: %__MODULE__{
      start_time: non_neg_integer(),
      end_time: non_neg_integer(),
      start_timezone: String.t(),
      end_timezone: String.t(),
      object: String.t(),
      time: non_neg_integer(),
      timezone: String.t(),
      start_date: String.t(),
      end_date: String.t(),
      date: String.t(),
    }
  end

  defmodule Conferencing do
    defstruct [
      :meeting_code,
      :password,
      :url,
      :phone,
      :pin,
    ]

    @type t :: %__MODULE__{
      meeting_code: String.t(),
      password: String.t(),
      url: String.t(),
      phone: [String.t()],
      pin: String.t(),
    }
  end

  def as_struct do
    %ExNylas.Event{
      participants: [%ExNylas.Event.Participant{email: nil}],
      when: %ExNylas.Event.When{},
      conferencing: %ExNylas.Event.Conferencing{},
      reminders: [%ExNylas.Event.Reminder{}],
      organizer: %ExNylas.Event.Organizer{},
    }
  end

  def as_list(), do: [as_struct()]

  defmodule Build do
    @enforce_keys [:calendar_id, :when]
    defstruct [
      :calendar_id,
      :when,
      :title,
      :description,
      :location,
      :participants,
      :busy,
      :recurrance,
      :visibility,
      :conferencing,
      :reminder_minutes,
      :reminder_method,
      :metadata,
      :notifications,
      :hide_participants,
    ]

    @typedoc "A struct representing the create event request payload."
    @type t :: %__MODULE__{
      calendar_id: String.t(),
      when: map(),
      title: String.t(),
      description: String.t(),
      location: String.t(),
      participants: list(),
      busy: boolean(),
      recurrance: map(),
      visibility: String.t(),
      conferencing: map(),
      reminder_minutes: String.t(),
      reminder_method: String.t(),
      metadata: map(),
      notifications: list(),
      hide_participants: boolean(),
    }
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
