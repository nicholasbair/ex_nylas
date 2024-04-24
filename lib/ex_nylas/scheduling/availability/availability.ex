defmodule ExNylas.Scheduling.Availability do
  @moduledoc """
  Interface for Nylas scheduling availability.
  """

  alias ExNylas.{
    API,
    Common.Availability,
    Common.Response
  }
  alias ExNylas.Connection, as: Conn

  use ExNylas,
    struct: Availability,
    readable_name: "scheduling availability",
    include: [:build]

  @doc """
  Get scheduling availability for a given time range.

  - `session_id` = `nil` is used for public scheduling configurations, but `config_id` is required in such cases.

  ## Examples

      iex> {:ok, availability} = ExNylas.Scheduling.Availability.get(conn, 1614556800, 1614643200)
  """
  @spec get(Conn.t(), integer(), integer(), String.t() | nil, String.t() | nil) :: {:ok, Response.t()} | {:error, Response.t()}
  def get(%Conn{} = conn, start_time, end_time, session_id \\ nil, config_id \\ nil) do
    Req.new(
      url: "#{conn.api_server}/v3/scheduling/availability",
      auth: auth_bearer(session_id),
      headers: API.base_headers(),
      query: %{
        start_time: start_time,
        end_time: end_time,
        config_id: config_id,
      }
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> API.handle_response(Availability)
  end

  @doc """
  Get scheduling availability for a given time range.

  - `session_id` = `nil` is used for public scheduling configurations, but `config_id` is required in such cases.

  ## Examples

      iex> availability = ExNylas.Scheduling.Availability.get!(conn, 1614556800, 1614643200)
  """
  @spec get!(Conn.t(), integer(), integer(), String.t() | nil, String.t() | nil) :: Response.t()
  def get!(%Conn{} = conn, start_time, end_time, session_id \\ nil, config_id \\ nil) do
    case get(conn, start_time, end_time, session_id, config_id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  defp auth_bearer(nil), do: nil
  defp auth_bearer(session_id) do
    {:bearer, session_id}
  end
end
