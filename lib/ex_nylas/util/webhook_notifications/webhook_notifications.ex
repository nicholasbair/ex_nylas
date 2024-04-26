defmodule ExNylas.WebhookNotifications do
  @moduledoc """
  Utility functions for webhook notifications.
  """

  alias ExNylas.WebhookNotification, as: Notification
  alias ExNylas.Transform, as: TF
  alias ExNylas.WebhookNotification.{
    Grant,
    MessageBounceDetected,
    MessageOpened,
    MessageLinkClicked,
    ThreadReplied
  }

  @doc """
  Transform a raw webhook notification into an ExNylas struct.

  ## Examples

      iex> {:ok, struct} = ExNylas.WebhookNotifications.to_struct(raw_payload)
  """
  @spec to_struct(map()) :: {:ok, Notification.t()} | {:error, String.t()}
  def to_struct(raw_notification) do
    notification = TF.preprocess_data(Notification, raw_notification)

    with {:ok, schema} <- type_to_schema(notification.type), object <- TF.preprocess_data(schema, notification.data.object) do
      {:ok, put_in(notification, [Access.key!(:data), Access.key!(:object)], object)}
    else
      {:error, _} -> {:error, "Failed to transform the webhook notification."}
    end
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
      {:error, msg} -> raise ExNylasError, msg
    end
  end

  @doc """
  Validate the X-Nylas-Signature header from a webhook.

  ## Examples

      valid = ExNylas.WebhoookNotification.valid_signature?(webhook_secret, body, signature_from_webhook_request)
  """
  @spec valid_signature?(String.t(), String.t(), String.t()) :: boolean()
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

  defp type_to_schema(type) when type in ["grant.created", "grant.updated", "grant.deleted", "grant.expired"] do
    {:ok, Grant}
  end

  defp type_to_schema(type) when type in ["message.bounce_detected"] do
    {:ok, MessageBounceDetected}
  end

  defp type_to_schema(type) when type in ["message.opened"] do
    {:ok, MessageOpened}
  end

  defp type_to_schema(type) when type in ["message.link_clicked"] do
    {:ok, MessageLinkClicked}
  end

  defp type_to_schema(type) when type in ["thread.replied"] do
    {:ok, ThreadReplied}
  end

  # Use the webhook trigger/type to determine the schema to use for transforming the data.
  # Non-standard cases are handled above.
  defp type_to_schema(type) do
    [hd | _] = String.split(type, ".")

    try do
      {:ok, Module.safe_concat([ExNylas, String.capitalize(hd)])}
    rescue
      _ -> {:error, "module not found"}
    end
  end
end
