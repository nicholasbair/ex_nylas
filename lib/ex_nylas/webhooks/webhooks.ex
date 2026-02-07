defmodule ExNylas.Webhooks do
  @moduledoc """
  Interface for Nylas webhook.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/webhook-notifications)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    ErrorHandler,
    Response,
    ResponseHandler,
    Telemetry,
    Webhook
  }

  use ExNylas,
    object: "webhooks",
    struct: ExNylas.Webhook,
    readable_name: "webhook",
    use_admin_url: true,
    include: [:list, :first, :find, :delete, :build, :create, :all]

  @doc """
  Update a webhook.

  ## Examples

      iex> {:ok, result} = ExNylas.Webhooks.update(conn, id, body, params)
  """
  @spec update(Connection.t(), String.t(), map(), Keyword.t() | map()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def update(%Connection{} = conn, id, changeset, params \\ []) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/#{id}",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: changeset,
      params: params
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.put(conn.options)
    |> ResponseHandler.handle_response(Webhook)
  end

  @doc """
  Update a webhook.

  ## Examples

      iex> result = ExNylas.Webhooks.update!(conn, id, body, params)
  """
  @spec update!(Connection.t(), String.t(), map(), Keyword.t() | map()) :: Response.t()
  def update!(%Connection{} = conn, id, changeset, params \\ []) do
    case update(conn, id, changeset, params) do
      {:ok, body} -> body
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end

  @doc """
  Rotate a webhook secret.

  ## Examples

      iex> {:ok, webhook} = ExNylas.Webhooks.rotate_secret(conn, webhook_id)
  """
  @spec rotate_secret(Connection.t(), String.t()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def rotate_secret(%Connection{} = conn, webhook_id) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/rotate-secret/#{webhook_id}",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(Webhook)
  end

  @doc """
  Rotate a webhook secret.

  ## Examples

      iex> webhook = ExNylas.Webhooks.rotate_secret(conn, webhook_id)
  """
  @spec rotate_secret!(Connection.t(), String.t()) :: Response.t()
  def rotate_secret!(%Connection{} = conn, webhook_id) do
    case rotate_secret(conn, webhook_id) do
      {:ok, body} -> body
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end

  @doc """
  Get a mock webhook payload.

  ## Examples

      iex> {:ok, payload} = ExNylas.Webhooks.mock_payload(conn, trigger)
  """
  @spec mock_payload(Connection.t(), String.t()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def mock_payload(%Connection{} = conn, trigger) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/mock-payload",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{trigger_type: trigger}
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response()
  end

  @doc """
  Get a mock webhook payload.

  ## Examples

      iex> payload = ExNylas.Webhooks.mock_payload(conn, trigger)
  """
  @spec mock_payload!(Connection.t(), String.t()) :: Response.t()
  def mock_payload!(%Connection{} = conn, trigger) do
    case mock_payload(conn, trigger) do
      {:ok, body} -> body
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end

  @doc """
  Send a test webhook event.

  ## Examples

      iex> {:ok, res} = ExNylas.Webhooks.send_test_event(conn, trigger, webhook_url)
  """
  @spec send_test_event(Connection.t(), String.t(), String.t()) ::
          {:ok, Response.t()} | {:error, ExNylas.error_reason()}
  def send_test_event(%Connection{} = conn, trigger, webhook_url) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/mock-payload",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{trigger_type: trigger, webhook_url: webhook_url}
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response()
  end

  @doc """
  Send a test webhook event.

  ## Examples

      iex> res = ExNylas.Webhooks.send_test_event(conn, trigger, webhook_url)
  """
  @spec send_test_event!(Connection.t(), String.t(), String.t()) :: Response.t()
  def send_test_event!(%Connection{} = conn, trigger, webhook_url) do
    case send_test_event(conn, trigger, webhook_url) do
      {:ok, body} -> body
      {:error, error} -> ErrorHandler.raise_error(error)
    end
  end
end
