defmodule ExNylas.CustomAuthentication do
  @moduledoc """
  Interface for Nylas custom authentication

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/authentication-apis)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    Grant,
    Response,
    ResponseHandler,
    Telemetry
  }

  use ExNylas,
    struct: __MODULE__,
    readable_name: "custom authentication",
    include: [:build]

  @doc """
  Connect a grant using custom authentication.

  ## Examples

      iex> {:ok, grant} = ExNylas.CustomAuthentication.connect(conn, body)
  """
  @spec connect(Connection.t(), map()) ::
          {:ok, Response.t()}
          | {:error,
               Response.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()}
  def connect(%Connection{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/connect/custom",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: body
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(Grant)
  end

  @doc """
  Connect a grant using custom authentication.

  ## Examples

      iex> grant = ExNylas.CustomAuthentication.connect!(conn, body)
  """
  @spec connect!(Connection.t(), map()) :: Response.t()
  def connect!(%Connection{} = conn, body) do
    case connect(conn, body) do
      {:ok, res} ->
        res

      {:error, %ExNylas.Response{error: %ExNylas.APIError{} = error}} ->
        raise error

      {:error, %ExNylas.Response{} = resp} ->
        raise ExNylas.APIError.exception(%{message: "API request failed with status #{resp.status}"})

      {:error, exception} ->
        raise exception
    end
  end
end
