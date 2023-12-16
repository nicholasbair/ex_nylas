defmodule ExNylas.Webhooks do
  @moduledoc """
  Interface for Nylas webhook.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  use ExNylas,
    object: "webhooks",
    struct: ExNylas.Model.Webhook,
    readable_name: "webhook",
    use_admin_url: true,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]

  @doc """
  Rotate a webhook secret.

  Example
      {:ok, webhook} = ExNylas.Webhooks.rotate_secret(conn, webhook_id)
  """
  def rotate_secret(%Conn{} = conn, webhook_id) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/rotate-secret/#{webhook_id}",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(),
      decode_body: false
    )
    |> Req.post(conn.options)
    |> API.handle_response(ExNylas.Model.Webhook.as_struct())
  end

  @doc """
  Rotate a webhook secret.

  Example
      webhook = ExNylas.Webhooks.rotate_secret(conn, webhook_id)
  """
  def rotate_secret!(%Conn{} = conn, webhook_id) do
    case rotate_secret(conn, webhook_id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Get a mock webhook payload.

  Example
      {:ok, payload} = ExNylas.Webhooks.mock_payload(conn, trigger)
  """
  def mock_payload(%Conn{} = conn, trigger) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/mock-payload",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{trigger_type: trigger},
      decode_body: false
    )
    |> Req.post(conn.options)
    |> API.handle_response()
  end

  @doc """
  Get a mock webhook payload.

  Example
      payload = ExNylas.Webhooks.mock_payload(conn, trigger)
  """
  def mock_payload!(%Conn{} = conn, trigger) do
    case mock_payload(conn, trigger) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send a test webhook event.

  Example
      {:ok, res} = ExNylas.Webhooks.send_test_event(conn, trigger, callback_url)
  """
  def send_test_event(%Conn{} = conn, trigger, callback_url) do
    Req.new(
      url: "#{conn.api_server}/v3/webhooks/mock-payload",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{trigger_type: trigger, callback_url: callback_url},
      decode_body: false
    )
    |> Req.post(conn.options)
    |> API.handle_response()
  end

  @doc """
  Send a test webhook event.

  Example
      res = ExNylas.Webhooks.send_test_event(conn, trigger, callback_url)
  """
  def send_test_event!(%Conn{} = conn, trigger, callback_url) do
    case send_test_event(conn, trigger, callback_url) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
