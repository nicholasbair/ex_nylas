defmodule ExNylas.WebhookNotificationData do
  @moduledoc """
  A struct representing the data field of a webhook notification.

  Note - data points to the inflated object that the webhook notification is about; trunacted message webhooks omit the message body.
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
    WebhookNotification.MessageOpened,
    WebhookNotification.MessageLinkClicked,
    WebhookNotification.ThreadReplied
  }

  # TypedEctoSchema and PolymorphicEmbed don't play nice together, so explicitly define the type
  @type t :: %__MODULE__{
          application_id: String.t(),
          object: struct()
        }

  @primary_key false

  embedded_schema do
    field :application_id, :string
    field :grant_id, :string # Message tracking webhooks include the grant_id here instead of within the nested object
    polymorphic_embeds_one :object,
      types: [
        "booking.created": Booking,
        "booking.cancelled": Booking,
        "booking.pending": Booking,
        "booking.rescheduled": Booking,

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
        "message.created.truncated": Message,
        "message.updated.truncated": Message,
        "message.send_success": Message,
        "message.send_failed": Message,
        "message.bounce_detected": MessageBounceDetected,
        "message.opened": MessageOpened,
        "message.link_clicked": MessageLinkClicked,

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
    |> then(&cast(struct, &1, [:application_id, :grant_id]))
    |> cast_polymorphic_embed(:object)
  end

  # Webhook trigger/type is the most reliable way to determine what notification.data.object should be transformed into.
  # Pass the trigger/type as params so it can be used by polymorphic_embeds_one.
  defp put_trigger(%{"trigger" => trigger, "object" => object} = params) do
    %{params | "object" => Map.put(object, "trigger", trigger)}
  end
end
