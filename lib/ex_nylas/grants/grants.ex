defmodule ExNylas.Grants do
  @moduledoc """
  Interface for Nylas grants.
  """

  alias ExNylas.API
  alias ExNylas.Common.Response
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Grant

  use ExNylas,
    object: "grants",
    struct: ExNylas.Grant,
    readable_name: "grant",
    include: [:list, :first, :find, :delete, :update, :all],
    use_admin_url: true,
    use_cursor_paging: false

  @doc """
  Get a grant using the current access token.

  ## Examples

      iex> {:ok, result} = ExNylas.Grants.me(conn)
  """
  @spec me(Conn.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def me(%Conn{} = conn) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/me",
      auth: API.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> API.handle_response(Grant)
  end
end
