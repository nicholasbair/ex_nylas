defmodule ExNylas.Calendars.FreeBusy do
  @moduledoc """
  Interface for Nylas calendar free/busy.
  """

  use TypedStruct
  use ExNylas,
    struct: __MODULE__,
    include: [:build]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  typedstruct do
    @typedoc "A calendar free busy"
    field(:object, String.t())
    field(:email, String.t())
    field(:timeslots, list())
  end

  typedstruct module: Build do
    @typedoc "A struct representing the calendar free-busy request payload."
    field(:start_time, non_neg_integer(), enforce: true)
    field(:end_time, non_neg_integer(), enforce: true)
    field(:emails, list(), enforce: true)
    field(:calendars, list())
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
    |> API.handle_response(__MODULE__)
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
