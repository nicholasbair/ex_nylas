defmodule ExNylas.Event do
  @moduledoc """
  A struct representing a event.
  """

  defstruct [
    :id,
    :object,
    :account_id,
    :calendar_id,
    :message_id,
    :title,
    :description,
    :owner,
    :participants,
    :read_only,
    :location,
    :when,
    :busy,
    :status,
    :ical_uid,
    :master_event_id,
    :original_start_time,
    :updated_at,
    :conferencing,
    :recurrence,
    :metadata,
    :notifications,
    :organizer_email,
    :organizer_name,
    :visibility,
    :hide_participants,
    :customer_event_id,
    :job_status_id,
  ]

  @typedoc "A event"
  @type t :: %__MODULE__{
    id: String.t(),
    object: String.t(),
    account_id: String.t(),
    calendar_id: String.t(),
    message_id: String.t(),
    title: String.t(),
    description: String.t(),
    owner: String.t(),
    participants: [ExNylas.Event.Participant.t()],
    read_only: boolean(),
    location: String.t(),
    when: ExNylas.Event.When.t(),
    busy: boolean(),
    status: String.t(),
    ical_uid: String.t(),
    master_event_id: String.t(),
    original_start_time: non_neg_integer(),
    updated_at: non_neg_integer(),
    conferencing: ExNylas.Event.Conferencing.t(),
    recurrence: ExNylas.Event.Recurrence.t(),
    metadata: map(),
    notifications: [ExNylas.Event.Notification.t()],
    organizer_email: String.t(),
    organizer_name: String.t(),
    visibility: String.t(),
    hide_participants: boolean(),
    customer_event_id: String.t(),
    job_status_id: String.t(),
  }

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

  defmodule Notification do
    defstruct [
      :type,
      :minutes_before_event,
      :body,
      :subject,
      :payload,
      :url,
    ]

    @type t :: %__MODULE__{
      type: String.t(),
      minutes_before_event: String.t(),
      body: String.t(),
      subject: String.t(),
      payload: String.t(),
      url: String.t(),
    }
  end

  defmodule Recurrence do
    defstruct [:rrule, :timezone,]

    @type t :: %__MODULE__{
      rrule: [String.t()],
      timezone: String.t(),
    }
  end

  def as_struct do
    %ExNylas.Event{
      participants: [%ExNylas.Event.Participant{email: nil}],
      when: %ExNylas.Event.When{},
      conferencing: %ExNylas.Event.Conferencing{},
      recurrence: %ExNylas.Event.Recurrence{},
      notifications: [%ExNylas.Event.Notification{}],
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
    include: [:list, :first, :find, :build, :all]

  @doc """
  Create an event

  Example
      {:ok, event} = conn |> ExNylas.Events.create(`body`)
  """
  def create(%Conn{} = conn, body, notify_participants \\ true) do
    API.post(
      "#{conn.api_server}/events",
      body,
      API.header_bearer(conn) ++ ["content-type": "application/json"],
      [params: %{notify_participants: notify_participants}]
    )
    |> API.handle_response(Event.as_struct())
  end

  @doc """
  Create an event

  Example
      event = conn |> ExNylas.Events.create!(`body`)
  """
  def create!(%Conn{} = conn, body, notify_participants \\ true) do
    case create(conn, body, notify_participants) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Update an event

  Example
      {:ok, event} = conn |> ExNylas.Events.update(`event_id`, `body`)
  """
  def update(%Conn{} = conn, event_id, body, notify_participants \\ true) do
    API.put(
      "#{conn.api_server}/events/#{event_id}",
        body,
        API.header_bearer(conn) ++ ["content-type": "application/json"],
        [params: %{notify_participants: notify_participants}]
    )
    |> API.handle_response(Event.as_struct())
  end

  @doc """
  Update an event

  Example
      event = conn |> ExNylas.Events.update!(`event_id`, `body`)
  """
  def update!(%Conn{} = conn, event_id, body, notify_participants \\ true) do
    case update(conn, event_id, body, notify_participants) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send an RSVP for a given event

  Example
      {:ok, success} = conn |> ExNylas.Events.rsvp(`event_id`, `status`, `account_id`)
  """
  def rsvp(%Conn{} = conn, event_id, status, account_id) do
    API.post(
      "#{conn.api_server}/send-rsvp",
      %{event_id: event_id, status: status, account_id: account_id},
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(Event.as_struct())
  end

  @doc """
  Send an RSVP for a given event

  Example
      success = conn |> ExNylas.Events.rsvp!(`event_id`, `status`, `account_id`)
  """
  def rsvp!(%Conn{} = conn, event_id, status, account_id) do
    case rsvp(conn, event_id, status, account_id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
