defmodule ExNylas.Grants do
  @moduledoc """
  Interface for Nylas grants.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Schema.Grant

  use ExNylas,
    object: "grants",
    struct: ExNylas.Schema.Grant,
    readable_name: "grant",
    include: [:list, :find, :delete, :update, :all],
    use_admin_url: true,
    use_cursor_paging: false

  @doc """
  Get a grant using the current access token.

  ## Examples

      iex> {:ok, result} = ExNylas.Grants.me(conn)
  """
  def me(%Conn{} = conn) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/me",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"])
    )
    |> Req.get(conn.options)
    |> API.handle_response(Grant)
  end
end