defmodule ExNylas.Grants do
  @moduledoc """
  Interface for Nylas grants.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/manage-grants)
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
  @spec me(Connection.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def me(%Connection{} = conn) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/me",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> ResponseHandler.handle_response(Grant)
  end

  @doc """
  Get a grant using the current access token.

  ## Examples

      iex> result = ExNylas.Grants.me!(conn)
  """
  @spec me!(Connection.t()) :: Response.t()
  def me!(%Connection{} = conn) do
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
  @spec refresh(Connection.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def refresh(%Connection{} = conn, refresh_token) do
    # Validate refresh token
    if is_nil(refresh_token) or refresh_token == "" do
      {:error, %Response{
        status: :bad_request,
        data: nil,
        error: %ExNylas.Error{message: "refresh_token cannot be nil or empty"}
      }}
    else
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
      |> Telemetry.maybe_attach_telemetry(conn)
      |> Req.post(conn.options)
      |> conditional_transform()
    end
  end

  @doc """
  Refresh a grant's access token using its refresh token.

  OAuth 2.0 access tokens expire after one hour. This function will raise an error
  if the refresh operation fails.

  ## Examples

      iex> result = ExNylas.Grants.refresh!(conn, "refresh-token")
  """
  @spec refresh!(Connection.t(), String.t()) :: Response.t()
  def refresh!(%Connection{} = conn, refresh_token) do
    case refresh(conn, refresh_token) do
      {:ok, response} -> response
      {:error, response} -> raise ExNylasError, response
    end
  end

  # The response from the API differs based on whether the request was successful or not
  # Pass the correct schema name to transform based on the response status
  # For successful responses (status 200), we use the ExNylas.HostedAuthentication.Grant schema
  # which matches the structure of the token endpoint response
  defp conditional_transform({:ok, %{status: 200}} = res) do
    ResponseHandler.handle_response(res, ExNylas.HostedAuthentication.Grant, false)
  end

  # For error responses, we use the default error handling
  defp conditional_transform(res) do
    ResponseHandler.handle_response(res)
  end
end
