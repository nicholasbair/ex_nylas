defmodule ExNylas.WebhookNotification do
  @moduledoc """
  Interface for Nylas webhook notifications.
  """

  @doc """
  Validate the X-Nylas-Signature header from a webhook.

  Example
      valid = ExNylas.WebhoookNotification.valid_signature?(webhook_secret, body, signature_from_webhook_request)
  """
  def valid_signature?(webhook_secret, _body, _signature) when is_nil(webhook_secret) do
    raise ExNylasError, "Webhook secret is required for this operation."
  end

  def valid_signature?(_webhook_secret, body, _signature) when not is_bitstring(body) do
    raise ExNylasError, "body should be passed as a string."
  end

  def valid_signature?(webhook_secret, body, signature) do
    :hmac
    |> :crypto.mac(:sha256, webhook_secret, body)
    |> Base.encode16
    |> String.downcase()
    |> Kernel.==(String.downcase(signature))
  end
end
