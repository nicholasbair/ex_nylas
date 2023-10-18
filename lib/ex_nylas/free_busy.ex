defmodule ExNylas.Calendars.FreeBusy do
  @moduledoc """
  Interface for Nylas calendar free/busy.
  """

  use ExNylas,
    struct: ExNylas.Model.Calendar.FreeBusy,
    include: [:build]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

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
