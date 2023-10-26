defmodule ExNylas.CustomAuthentication do
  @moduledoc """
  Interface for Nylas custom authentication
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Connect a grant using custom authentication.

  Example
      {:ok, grant} = conn |> ExNylas.CustomAuthentication.connect(`body`)
  """
  def connect(%Conn{} = conn, body) do
    API.post(
      "#{conn.api_server}/v3/connect/custom",
      body,
      API.header_bearer(conn) ++ ["content-type": "application/json"],
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.Grant.as_struct())
  end

  @doc """
  Connect a grant using custom authentication.

  Example
      grant = conn |> ExNylas.CustomAuthentication.connect!(`body`)
  """
  def connect!(%Conn{} = conn, body) do
    case connect(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
