defmodule ExNylas.Grants do
  @moduledoc """
  Interface for Nylas grants.
  """

  alias ExNylas.API
  alias ExNylas.Response
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Grant

  use ExNylas,
    object: "grants",
    struct: ExNylas.Grant,
    readable_name: "grant",
    include: [:list, :first, :find, :delete, :all],
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

  @doc """
  Get a grant using the current access token.

  ## Examples

      iex> result = ExNylas.Grants.me!(conn)
  """
  @spec me!(Conn.t()) :: Response.t()
  def me!(%Conn{} = conn) do
    case me(conn) do
      {:ok, response} -> response
      {:error, response} -> raise ExNylasError, response
    end
  end

  @doc """
  Refresh a grant's access token using its refresh token.
  
  OAuth 2.0 access tokens expire after one hour. When the access token expires, 
  you can use the refresh token to get a new access token.

  ## Examples

      iex> {:ok, result} = ExNylas.Grants.refresh(conn, "refresh-token")
  """
  @spec refresh(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def refresh(%Conn{} = conn, refresh_token) do
    body = %{
      client_id: conn.client_id,
      client_secret: conn.api_key,
      grant_type: "refresh_token",
      refresh_token: refresh_token
    }

    Req.new(
      url: "#{conn.api_server}/v3/connect/token",
      headers: API.base_headers(),
      json: body
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> conditional_transform()
  end

  @doc """
  Refresh a grant's access token using its refresh token.
  
  OAuth 2.0 access tokens expire after one hour. This function will raise an error
  if the refresh operation fails.

  ## Examples

      iex> result = ExNylas.Grants.refresh!(conn, "refresh-token")
  """
  @spec refresh!(Conn.t(), String.t()) :: Response.t()
  def refresh!(%Conn{} = conn, refresh_token) do
    case refresh(conn, refresh_token) do
      {:ok, response} -> response
      {:error, response} -> raise ExNylasError, response
    end
  end
  
  # The response from the API differs based on whether the request was successful or not
  # Pass the correct schema name to transform based on the response status
  defp conditional_transform({:ok, %{status: 200}} = res) do
    API.handle_response(res, ExNylas.HostedAuthentication.Grant, false)
  end

  defp conditional_transform(res) do
    API.handle_response(res)
  end
end
