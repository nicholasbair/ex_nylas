defmodule ExNylas.CustomAuthentication do
  @moduledoc """
  Interface for Nylas custom authentication
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Connect a grant using custom authentication.

  Example
      {:ok, grant} = ExNylas.CustomAuthentication.connect(conn, body)
  """
  def connect(%Conn{} = conn, body) do
    Req.new(
      url: "#{conn.api_server}/v3/connect/custom",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      body: API.process_request_body(body),
      decode_body: false
    )
    |> Req.post(conn.options)
    |> API.handle_response(ExNylas.Model.Grant.as_struct())
  end

  @doc """
  Connect a grant using custom authentication.

  Example
      grant = ExNylas.CustomAuthentication.connect!(conn, body)
  """
  def connect!(%Conn{} = conn, body) do
    case connect(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
