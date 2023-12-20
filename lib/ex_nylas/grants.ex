defmodule ExNylas.Grants do
  @moduledoc """
  Interface for Nylas grants.
  """

  use ExNylas,
    object: "grants",
    struct: ExNylas.Model.Grant,
    readable_name: "grant",
    include: [:list, :find, :delete, :update, :all],
    use_admin_url: true,
    use_cursor_paging: false

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Get a grant using the current access token.

  ## Examples

      iex> {:ok, result} = ExNylas.Grants.me(conn)
  """
  def me(%Conn{} = conn) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/me",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      decode_body: false
    )
    |> Req.get(conn.options)
    |> API.handle_response(ExNylas.Model.Grant.as_struct())
  end
end
