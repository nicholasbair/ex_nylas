defmodule ExNylas.WebhookNotifications do
  @moduledoc """
  Utility functions for webhook notifications.
  """

  import Ecto.Changeset
  alias ExNylas.WebhookNotification, as: Notification

  @doc """
  Transform a raw webhook notification into an ExNylas struct.

  ## Examples

      iex> {:ok, struct} = ExNylas.WebhookNotifications.to_struct(raw_payload)
  """
  @spec to_struct(map()) :: {:ok, Notification.t()} | {:error, Ecto.Changeset.t()}
  def to_struct(raw_notification) do
    %Notification{}
    |> Notification.changeset(raw_notification)
    |> apply_action(:create)
  end

  @doc """
  Transform a raw webhook notification into an ExNylas struct.

  ## Examples

    iex> struct = ExNylas.WebhookNotifications.to_struct!(raw_payload)
  """
  @spec to_struct!(map()) :: Notification.t()
  def to_struct!(raw_notification) do
    case to_struct(raw_notification) do
      {:ok, notification} -> notification
      {:error, _changeset} -> raise ExNylasError, "Failed to transform the webhook notification."
    end
  end

  @doc """
  Validate the X-Nylas-Signature header from a webhook.

  ## Examples

      iex> {:ok, match?} = ExNylas.WebhoookNotification.validate_signature(webhook_secret, body, signature_from_webhook_request)
  """
  @spec validate_signature(String.t(), String.t(), String.t()) :: {:ok, boolean()} | {:error, String.t()}
  def validate_signature(webhook_secret, _body, _signature) when is_nil(webhook_secret) do
    {:error, "Webhook secret is required for this operation."}
  end

  def validate_signature(_webhook_secret, body, _signature) when not is_bitstring(body) do
    {:error, "body should be passed as a string."}
  end

  def validate_signature(_webhook_secret, _, signature) when not is_bitstring(signature) do
    {:error, "signature should be passed as a string."}
  end

  def validate_signature(webhook_secret, body, signature) do
    match? =
      :hmac
      |> :crypto.mac(:sha256, webhook_secret, body)
      |> Base.encode16
      |> String.downcase()
      |> Kernel.==(String.downcase(signature))

    {:ok, match?}
  end

  @doc """
  Validate the X-Nylas-Signature header from a webhook.

  ## Examples

      iex> valid = ExNylas.WebhoookNotification.validate_signature!(webhook_secret, body, signature_from_webhook_request)
  """
  @spec validate_signature!(String.t(), String.t(), String.t()) :: boolean()
  def validate_signature!(webhook_secret, body, signature) do
    case validate_signature(webhook_secret, body, signature) do
      {:ok, match?} ->
        match?

      {:error, msg} ->
        raise ExNylasError, msg
    end
  end
end
