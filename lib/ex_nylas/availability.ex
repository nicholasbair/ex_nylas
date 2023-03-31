defmodule ExNylas.Calendars.Availability do
  @moduledoc """
  Interface for Nylas calendar availability.
  """
  use ExNylas,
    struct: __MODULE__,
    include: [:build]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  defstruct [:object, :timeslots]

  @type t :: %__MODULE__{
    object: String.t(),
    timeslots: [ExNylas.Calendars.Availability.TimeSlot.t()]
  }

  defmodule TimeSlot do
    defstruct [
      :object,
      :status,
      :start,
      :end,
    ]

    @type t :: %__MODULE__{
      object: String.t(),
      status: String.t(),
      start: non_neg_integer(),
      end: non_neg_integer(),
    }

    def as_struct() do
      %ExNylas.Calendars.Availability.TimeSlot{}
    end
  end

  def as_struct() do
    %ExNylas.Calendars.Availability{
      timeslots: [ExNylas.Calendars.Availability.TimeSlot.as_struct()]
    }
  end

  defmodule Build do
    @enforce_keys [:duration_minutes, :start_time, :end_time, :interval_minutes, :emails]
    defstruct [
      :duration_minutes,
      :start_time,
      :end_time,
      :interval_minutes,
      :round_start,
      :emails,
      :free_busy,
      :open_hours,
      :tentative_busy,
      :round_robin,
      :buffer,
      :calendars,
    ]

    @typedoc "A struct representing the calendar availability request payload."
    @type t :: %__MODULE__{
      duration_minutes: non_neg_integer(),
      start_time: non_neg_integer(),
      end_time: non_neg_integer(),
      interval_minutes: non_neg_integer(),
      round_start: boolean(),
      emails: list(),
      free_busy: list(),
      open_hours: list(),
      tentative_busy: boolean(),
      round_robin: String.t(),
      buffer: non_neg_integer(),
      calendars: list(),
    }
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
    |> API.handle_response(ExNylas.Calendars.Availability.as_struct())
  end

  defp availability_consecutive(%Conn{} = conn, body) do
    API.post(
      "#{conn.api_server}/calendars/availability/consecutive",
      body,
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Calendars.Availability.as_struct())
  end
end
