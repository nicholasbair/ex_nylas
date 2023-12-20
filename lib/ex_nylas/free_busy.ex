defmodule ExNylas.Calendars.FreeBusy do
  @moduledoc """
  Interface for Nylas calendar free/busy.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Model.Calendar.FreeBusy, as: FB

  use ExNylas,
    struct: ExNylas.Model.Calendar.FreeBusy,
    readable_name: "calendar free/busy",
    include: [:build]

  @doc """
  Get calendar free/busy.

  ## Examples

      iex> {:ok, result} = ExNylas.Calendars.FreeBusy.list(conn, body)
  """
  def list(%Conn{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/calendars/free-busy",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      body: API.process_request_body(body),
      decode_body: false
    )
    |> Req.post(conn.options)
    |> API.handle_response(FB.as_list())
  end

  @doc """
  Get calendar free/busy.

  ## Examples

      iex> result = ExNylas.Calendars.FreeBusy.list!(conn, body)
  """
  def list!(%Conn{} = conn, body) do
    case list(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
