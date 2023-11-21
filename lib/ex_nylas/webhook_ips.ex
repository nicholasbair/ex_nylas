defmodule ExNylas.WebhookIPs do
  @moduledoc """
  Interface for Nylas webhook IPs.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Get webhook IPs.

  Example
      {:ok, result} = conn |> ExNylas.WebhookIps.list()
  """
  def list(%Conn{} = conn) do
    API.get(
      "#{conn.api_server}/v3/webhooks/ip-addresses",
      API.header_bearer(conn) ++ ["content-type": "application/json"],
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.WebhookIP.as_struct())
  end
end
