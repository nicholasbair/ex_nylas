defmodule ExNylas.Webhooks do
  @moduledoc """
  Interface for Nylas webhook.
  """

  alias ExNylas.API
  alias ExNylas.Response
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Webhook

  use ExNylas,
    object: "webhooks",
    struct: ExNylas.Webhook,
    readable_name: "webhook",
    use_admin_url: true,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]

  @doc """
  Rotate a webhook secret.

  ## Examples

      iex> {:ok, webhook} = ExNylas.Webhooks.rotate_secret(conn, webhook_id)
  """
  @spec rotate_secret(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def rotate_secret(%Conn{} = conn, webhook_id) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/rotate-secret/#{webhook_id}",
      auth: API.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(Webhook)
  end

  @doc """
  Rotate a webhook secret.

  ## Examples

      iex> webhook = ExNylas.Webhooks.rotate_secret(conn, webhook_id)
  """
  @spec rotate_secret!(Conn.t(), String.t()) :: Response.t()
  def rotate_secret!(%Conn{} = conn, webhook_id) do
    case rotate_secret(conn, webhook_id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Get a mock webhook payload.

  ## Examples

      iex> {:ok, payload} = ExNylas.Webhooks.mock_payload(conn, trigger)
  """
  @spec mock_payload(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def mock_payload(%Conn{} = conn, trigger) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/mock-payload",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{trigger_type: trigger}
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response()
  end

  @doc """
  Get a mock webhook payload.

  ## Examples

      iex> payload = ExNylas.Webhooks.mock_payload(conn, trigger)
  """
  @spec mock_payload!(Conn.t(), String.t()) :: Response.t()
  def mock_payload!(%Conn{} = conn, trigger) do
    case mock_payload(conn, trigger) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send a test webhook event.

  ## Examples

      iex> {:ok, res} = ExNylas.Webhooks.send_test_event(conn, trigger, webhook_url)
  """
  @spec send_test_event(Conn.t(), String.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def send_test_event(%Conn{} = conn, trigger, webhook_url) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/mock-payload",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{trigger_type: trigger, webhook_url: webhook_url}
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response()
  end

  @doc """
  Send a test webhook event.

  ## Examples

      iex> res = ExNylas.Webhooks.send_test_event(conn, trigger, webhook_url)
  """
  @spec send_test_event!(Conn.t(), String.t(), String.t()) :: Response.t()
  def send_test_event!(%Conn{} = conn, trigger, webhook_url) do
    case send_test_event(conn, trigger, webhook_url) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
