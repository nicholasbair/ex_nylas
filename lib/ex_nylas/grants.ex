defmodule ExNylas.Grants do
  @moduledoc """
  Interface for Nylas grants.
  """

  use ExNylas,
    object: "grants",
    struct: ExNylas.Model.Grant,
    readable_name: "grant",
    include: [:list, :find, :delete, :update],
    use_admin_url: true

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Get a grant using the current access token.

  Example
      {:ok, result} = conn |> ExNylas.Grants.me()
  """
  def me(%Conn{} = conn) do
    API.get(
      "#{conn.api_server}/v3/grants/me",
      API.header_bearer(conn) ++ ["content-type": "application/json"],
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.Grant.as_struct())
  end
end
