defmodule ExNylas.CustomAuthentication do
  @moduledoc """
  Interface for Nylas custom authentication

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/authentication-apis)
  """

  alias ExNylas.API
  alias ExNylas.Response
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Grant

  use ExNylas,
    struct: __MODULE__,
    readable_name: "custom authentication",
    include: [:build]

  @doc """
  Connect a grant using custom authentication.

  ## Examples

      iex> {:ok, grant} = ExNylas.CustomAuthentication.connect(conn, body)
  """
  @spec connect(Conn.t(), map()) :: {:ok, Response.t()} | {:error, Response.t()}
  def connect(%Conn{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/connect/custom",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: body
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(Grant)
  end

  @doc """
  Connect a grant using custom authentication.

  ## Examples

      iex> grant = ExNylas.CustomAuthentication.connect!(conn, body)
  """
  @spec connect!(Conn.t(), map()) :: Response.t()
  def connect!(%Conn{} = conn, body) do
    case connect(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
