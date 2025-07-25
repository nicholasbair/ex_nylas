defmodule ExNylas.WebhookNotificationData do
  @moduledoc """
  A struct representing the data field of a webhook notification.

  Note - data points to the inflated object that the webhook notification is about; trunacted message webhooks omit the message body.

  [Nylas docs](https://developer.nylas.com/docs/v3/notifications/notification-schemas/)
  """

  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  alias ExNylas.{
    Calendar,
    Contact,
    Event,
    Folder,
    Message,
    WebhookNotification.Booking,
    WebhookNotification.Grant,
    WebhookNotification.MessageBounceDetected,
    WebhookNotification.MessageLinkClicked,
    WebhookNotification.MessageOpened,
    WebhookNotification.Notetaker,
    WebhookNotification.NotetakerMedia,
    WebhookNotification.Order,
    WebhookNotification.ThreadReplied,
    WebhookNotification.Tracking
  }

  # TypedEctoSchema and PolymorphicEmbed don't play nice together, so explicitly define the type
  @type t :: %__MODULE__{
          application_id: String.t(),
          object: struct()
        }

  @primary_key false

  embedded_schema do
    field(:application_id, :string)
    polymorphic_embeds_one :object,
      types: [
        "booking.created": Booking,
        "booking.cancelled": Booking,
        "booking.pending": Booking,
        "booking.rescheduled": Booking,
        "booking.reminder": Booking,

        "calendar.created": Calendar,
        "calendar.updated": Calendar,
        "calendar.deleted": Calendar,

        "contact.updated": Contact,
        "contact.deleted": Contact,

        "event.created": Event,
        "event.updated": Event,
        "event.deleted": Event,

        "folder.created": Folder,
        "folder.updated": Folder,
        "folder.deleted": Folder,

        "grant.created": Grant,
        "grant.updated": Grant,
        "grant.deleted": Grant,
        "grant.expired": Grant,

        "message.created": Message,
        "message.updated": Message,
        "message.send_success": Message,
        "message.send_failed": Message,
        "message.bounce_detected": MessageBounceDetected,
        "message.opened": MessageOpened,
        "message.link_clicked": MessageLinkClicked,
        "message.intelligence.order": Order,
        "message.intelligence.tracking": Tracking,

        "notetaker.created": Notetaker,
        "notetaker.updated": Notetaker,
        "notetaker.meeting_state": Notetaker,
        "notetaker.deleted": Notetaker,
        "notetaker.media": NotetakerMedia,

        "thread.replied": ThreadReplied,
      ],
      on_type_not_found: :changeset_error,
      on_replace: :update,
      type_field_name: :trigger
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    params
    |> put_trigger()
    |> then(&cast(struct, &1, [:application_id]))
    |> cast_polymorphic_embed(:object)
  end

  # Webhook trigger/type is the most reliable way to determine what notification.data.object should be transformed into.
  # Pass the trigger/type as params so it can be used by polymorphic_embeds_one.
  defp put_trigger(%{"trigger" => trigger, "object" => object} = params) do
    %{params | "object" => Map.put(object, "trigger", to_parent_trigger(trigger))}
  end

  defp to_parent_trigger(trigger) when is_binary(trigger) do
    String.replace(trigger, ~r/\.(truncated|transformed|transformed.truncated)$/, "")
  end
end
