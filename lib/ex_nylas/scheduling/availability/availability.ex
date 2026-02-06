defmodule ExNylas.Scheduling.Availability do
  @moduledoc """
  Interface for Nylas scheduling availability.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/scheduler/)
  """

  alias ExNylas.{
    API,
    Availability,
    Connection,
    Response,
    ResponseHandler,
    Telemetry
  }

  use ExNylas,
    struct: Availability,
    readable_name: "scheduling availability",
    include: [:build]

  @doc """
  Get scheduling availability for a given time range.

  ## Params
  - `session_id` needed for private scheduling configurations
  - `config_id` needed for public scheduling configurations
  - `slug` slug of the scheduling configuration, can be used instead of `config_id`
  - `booking_id` needed to check availability when rescheduling a round robin booking

  ## Examples

      iex> {:ok, availability} = ExNylas.Scheduling.Availability.get(conn, 1614556800, 1614643200, config_id: "1234-5678")
  """
  @spec get(Connection.t(), integer(), integer(), Keyword.t()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def get(%Connection{} = conn, start_time, end_time, params \\ []) do
    Req.new(
      url: "#{conn.api_server}/v3/scheduling/availability",
      auth: auth_bearer(params[:session_id]),
      headers: API.base_headers(),
      params: Keyword.merge(params, [
        start_time: start_time,
        end_time: end_time
      ])
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> ResponseHandler.handle_response(Availability)
  end

  @doc """
  Get scheduling availability for a given time range.

  ## Params
  - `session_id` needed for private scheduling configurations
  - `config_id` needed for public scheduling configurations
  - `slug` slug of the scheduling configuration, can be used instead of `config_id`
  - `booking_id` needed to check availability when rescheduling a round robin booking

  ## Examples

      iex> availability = ExNylas.Scheduling.Availability.get!(conn, 1614556800, 1614643200, config_id: "1234-5678")
  """
  @spec get!(Connection.t(), integer(), integer(), Keyword.t()) :: Response.t()
  def get!(%Connection{} = conn, start_time, end_time, params \\ []) do
    case get(conn, start_time, end_time, params) do
      {:ok, body} ->
        body

      {:error, %ExNylas.Response{error: %ExNylas.APIError{} = error}} ->
        raise error

      {:error, %ExNylas.Response{} = resp} ->
        raise ExNylas.APIError.exception(%{message: "API request failed with status #{resp.status}"})

      {:error, exception} ->
        raise exception
    end
  end

  defp auth_bearer(nil), do: nil
  defp auth_bearer(session_id) do
    {:bearer, session_id}
  end
end
