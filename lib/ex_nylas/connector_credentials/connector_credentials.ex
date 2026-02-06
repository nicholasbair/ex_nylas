defmodule ExNylas.ConnectorCredentials do
  @moduledoc """
  Interface for Nylas connector credentials.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/connector-credentials)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    ConnectorCredential,
    ErrorHandler,
    Response,
    ResponseHandler,
    Telemetry
  }

  use ExNylas,
    struct: ConnectorCredential,
    readable_name: "connector credential",
    include: [:build]

  @doc """
  List connector credentials.

  Example
      {:ok, creds} = ExNylas.ConnectorCredentials.list(conn, provider)
  """
  @spec list(Connection.t(), String.t() | atom(), Keyword.t() | list()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def list(%Connection{} = conn, provider, params \\ []) do
    Req.new(
      url: "#{conn.api_server}/v3/connectors/#{provider}/creds",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(),
      params: params
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> ResponseHandler.handle_response(ConnectorCredential)
  end

  @doc """
  List connector credentials.

  Example
      creds = ExNylas.ConnectorCredentials.list!(conn, provider)
  """
  @spec list!(Connection.t(), String.t() | atom(), Keyword.t() | list()) :: Response.t()
  def list!(%Connection{} = conn, provider, params \\ []) do
    case list(conn, provider, params) do
      {:ok, res} -> res
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end

  @doc """
  Create a connector credential.

  Example
      {:ok, cred} = ExNylas.ConnectorCredentials.create(conn, provider, body)
  """
  @spec create(Connection.t(), String.t() | atom(), map()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def create(%Connection{} = conn, provider, body) do
    Req.new(
      url: "#{conn.api_server}/v3/connectors/#{provider}/creds",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: body
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(ConnectorCredential)
  end

  @doc """
  Create a connector credential.

  Example
      cred = ExNylas.ConnectorCredentials.create!(conn, provider, body)
  """
  @spec create!(Connection.t(), String.t() | atom(), map()) :: Response.t()
  def create!(%Connection{} = conn, provider, body) do
    case create(conn, provider, body) do
      {:ok, res} -> res
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end

  @doc """
  Find a connector credential.

  Example
      {:ok, cred} = ExNylas.ConnectorCredentials.find(conn, provider, id)
  """
  @spec find(Connection.t(), String.t() | atom(), String.t()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def find(%Connection{} = conn, provider, id) do
    Req.new(
      url: "#{conn.api_server}/v3/connectors/#{provider}/creds/#{id}",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> ResponseHandler.handle_response(ConnectorCredential)
  end

  @doc """
  Find a connector credential.

  Example
      cred = ExNylas.ConnectorCredentials.find(conn, provider, id)
  """
  @spec find!(Connection.t(), String.t() | atom(), String.t()) :: Response.t()
  def find!(%Connection{} = conn, provider, id) do
    case find(conn, provider, id) do
      {:ok, res} -> res
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end

  @doc """
  Delete a connector credential.

  Example
      {:ok, res} = ExNylas.ConnectorCredentials.delete(conn, provider, id)
  """
  @spec delete(Connection.t(), String.t() | atom(), String.t()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def delete(%Connection{} = conn, provider, id) do
    Req.new(
      url: "#{conn.api_server}/v3/connectors/#{provider}/creds/#{id}",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.delete(conn.options)
    |> ResponseHandler.handle_response()
  end

  @doc """
  Delete a connector credential.

  Example
      res = ExNylas.ConnectorCredentials.delete!(conn, provider, id)
  """
  @spec delete!(Connection.t(), String.t() | atom(), String.t()) :: Response.t()
  def delete!(%Connection{} = conn, provider, id) do
    case delete(conn, provider, id) do
      {:ok, res} -> res
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end

  @doc """
  Update a connector credential.

  ## Examples

      iex> {:ok, cred} = ExNylas.ConnectorCredentials.update(conn, provider, id, changeset)
  """
  @spec update(Connection.t(), String.t() | atom(), String.t(), map()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def update(%Connection{} = conn, provider, id, changeset) do
    Req.new(
      url: "#{conn.api_server}/v3/connectors/#{provider}/creds/#{id}",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: changeset
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.patch(conn.options)
    |> ResponseHandler.handle_response(ConnectorCredential)
  end

  @doc """
  Update a connector credential.

  ## Examples

      iex> cred = ExNylas.ConnectorCredentials.update!(conn, provider, id, changeset)
  """
  @spec update!(Connection.t(), String.t() | atom(), String.t(), map()) :: Response.t()
  def update!(%Connection{} = conn, provider, id, changeset) do
    case update(conn, provider, id, changeset) do
      {:ok, res} -> res
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end
end
