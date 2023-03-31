defmodule ExNylas.Calendars.FreeBusy do
  @moduledoc """
  Interface for Nylas calendar free/busy.
  """

  use ExNylas,
    struct: __MODULE__,
    include: [:build]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  defstruct [
    :object,
    :email,
    :calendar_id,
    :timeslots,
  ]

  @typedoc "A calendar free busy"
  @type t :: %__MODULE__{
    object: String.t(),
    email: String.t(),
    calendar_id: String.t(),
    timeslots: [ExNylas.Calendars.FreeBusy.TimeSlot.t()],
  }

  defmodule TimeSlot do
    defstruct [
      :object,
      :status,
      :start_time,
      :end_time,
    ]

    @type t :: %__MODULE__{
      object: String.t(),
      status: String.t(),
      start_time: non_neg_integer(),
      end_time: non_neg_integer(),
    }

    def as_struct() do
      %ExNylas.Calendars.FreeBusy.TimeSlot{}
    end
  end

  def as_struct() do
    %ExNylas.Calendars.FreeBusy{
      timeslots: ExNylas.Calendars.FreeBusy.TimeSlot.as_struct()
    }
  end

  def as_list(), do: [as_struct()]

  defmodule Build do
    @enforce_keys [:start_time, :end_time, :emails]
    defstruct [
      :start_time,
      :end_time,
      :emails,
      :calendars,
    ]

    @typedoc "A struct representing the calendar free-busy request payload."
    @type t :: %__MODULE__{
      start_time: non_neg_integer(),
      end_time: non_neg_integer(),
      emails: list(),
      calendars: list(),
    }
  end

  @doc """
  Get calendar free/busy.

  Example
      {:ok, result} = conn |> ExNylas.Calendars.FreeBusy.list(`body`)
  """
  def list(%Conn{} = conn, body) do
    API.post(
      "#{conn.api_server}/calendars/free-busy",
      body,
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Calendars.FreeBusy.as_list())
  end

  @doc """
  Get calendar free/busy.

  Example
      result = conn |> ExNylas.Calendars.FreeBusy.list!(`body`)
  """
  def list!(%Conn{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end


end
