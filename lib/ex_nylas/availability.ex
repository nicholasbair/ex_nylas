defmodule ExNylas.Calendars.Availability do
  @moduledoc """
  Interface for Nylas calendar availability.
  """
  use ExNylas,
    struct: __MODULE__,
    include: [:build]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  defstruct [:order, :time_slots]

  @type t :: %__MODULE__{
    order: [String.t()],
    time_slots: [ExNylas.Calendars.Availability.TimeSlot.t()]
  }

  defmodule TimeSlot do
    defstruct [
      :emails,
      :start_time,
      :end_time,
    ]

    @type t :: %__MODULE__{
      emails: list(),
      start_time: non_neg_integer(),
      end_time: non_neg_integer(),
    }

    def as_struct() do
      %ExNylas.Calendars.Availability.TimeSlot{}
    end
  end

  def as_struct(), do: %ExNylas.Calendars.Availability{}

  defmodule Build do
    @enforce_keys [:participants, :start_time, :end_time, :duration_minutes]
    defstruct [
      :participants,
      :start_time,
      :end_time,
      :duration_minutes,
      :interval_minutes,
      :round_to_30_minutes,
      :availability_rules,
    ]

    @typedoc "A struct representing the calendar availability request payload."
    @type t :: %__MODULE__{
      participants: [ExNylas.Calendars.Availability.Build.Participant.t()],
      start_time: non_neg_integer(),
      end_time: non_neg_integer(),
      duration_minutes: non_neg_integer(),
      interval_minutes: non_neg_integer(),
      round_to_30_minutes: boolean(),
      availability_rules: [ExNylas.Calendars.Availability.AvailabilityRule.t()],
    }

    defmodule Participant do
      defstruct [
        :email,
        :calendar_ids,
        :open_hours,
      ]

      @type t :: %__MODULE__{
        email: String.t(),
        calendar_ids: [String.t()],
        open_hours: [ExNylas.Calendars.Availability.Build.OpenHour.t()],
      }
    end

    defmodule OpenHour do
      defstruct [
        :days,
        :timezone,
        :start,
        :end,
        :exdates,
      ]

      @type t :: %__MODULE__{
        days: [integer()],
        timezone: String.t(),
        start: String.t(),
        end: String.t(),
        exdates: [String.t()],
      }
    end

    defmodule AvailabilityRule do
      defstruct [
        :availability_method,
        :buffer,
        :default_open_hours,
        :round_robin_group_id,
      ]

      @type t :: %__MODULE__{
        availability_method: String.t(),
        buffer: non_neg_integer(),
        default_open_hours: [ExNylas.Calendars.Availability.Build.OpenHour.t()],
        round_robin_group_id: String.t(),
      }
    end
  end

  @doc """
  Get calendar availability.

  Example
      {:ok, result} = conn |> ExNylas.Calendars.Availability.list(`body`)
  """
  def list(%Conn{} = conn, body) do
    API.post(
      "#{conn.api_server}/v3/calendars/availability",
      body,
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Calendars.Availability.as_struct())
  end

  @doc """
  Get calendar availability.

  Example
      result = conn |> ExNylas.Calendars.Availability.list!(`body`)
  """
  def list!(%Conn{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
