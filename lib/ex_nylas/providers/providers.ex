defmodule ExNylas.Providers do
  @moduledoc """
  Interface for Nylas providers.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/connectors-integrations)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    Provider,
    Response,
    ResponseHandler,
    Telemetry
  }

  @doc """
  Detect the provider for an email address.

  ## Examples

      iex> {:ok,  detect} = ExNylas.Providers.detect(conn, %{email: email} = _params)
  """
  @spec detect(Connection.t(), Keyword.t() | list()) :: {:ok, Response.t()} | {:error, ExNylas.APIError.t() | ExNylas.TransportError.t()}
  def detect(%Connection{} = conn, params \\ []) do
    Req.new(
      url: "#{conn.api_server}/v3/providers/detect",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(),
      params: params
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(Provider)
  end

  @doc """
  Detect the provider for an email address.

  ## Examples

      iex> detect = ExNylas.Providers.detect(conn, %{email: email} = _params)
  """
  @spec detect!(Connection.t(), Keyword.t() | list()) :: Response.t()
  def detect!(%Connection{} = conn, params \\ []) do
    case detect(conn, params) do
      {:ok, body} -> body
      {:error, exception} -> raise exception
    end
  end
end
