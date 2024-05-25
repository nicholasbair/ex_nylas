defmodule ExNylas.WebhookNotificationData do
  @moduledoc """
  A struct representing the data field of a webhook notification.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  @trigger_to_schema  [
    "calendar.created": ExNylas.Calendar,
    "calendar.updated": ExNylas.Calendar,
    "calendar.deleted": ExNylas.Calendar,

    "contact.updated": ExNylas.Contact,
    "contact.deleted": ExNylas.Contact,

    "event.created": ExNylas.Event,
    "event.updated": ExNylas.Event,
    "event.deleted": ExNylas.Event,

    "folder.created": ExNylas.Folder,
    "folder.updated": ExNylas.Folder,
    "folder.deleted": ExNylas.Folder,

    "grant.created": ExNylas.WebhookNotification.Grant,
    "grant.updated": ExNylas.WebhookNotification.Grant,
    "grant.deleted": ExNylas.WebhookNotification.Grant,
    "grant.expired": ExNylas.WebhookNotification.Grant,

    "message.created": ExNylas.Message,
    "message.updated": ExNylas.Message,
    "message.send_success": ExNylas.Message,
    "message.send_failed": ExNylas.Message,
    "message.bounce_detected": ExNylas.WebhookNotification.MessageBounceDetected,

    "message.opened": ExNylas.WebhookNotification.MessageOpened,
    "message.link_clicked": ExNylas.WebhookNotification.MessageLinkClicked,
    "thread.replied": ExNylas.WebhookNotification.ThreadReplied,
  ]

  @type t :: %__MODULE__{
          application_id: String.t(),
          object: struct()
        }

  @primary_key false

  embedded_schema do
    field :application_id, :string
    polymorphic_embeds_one :object,
      types: @trigger_to_schema,
      on_type_not_found: :changeset_error,
      on_replace: :update,
      type_field: :trigger
  end

  def changeset(struct, params \\ %{}) do
    params = put_trigger(params)

    struct
    |> cast(params, [:application_id])
    |> cast_polymorphic_embed(:object)
  end

  # Webhook trigger/type is the most reliable way to determine what notification.data.object should be transformed into.
  # Pass the trigger/type as params so it can be used by polymorphic_embeds_one.
  defp put_trigger(%{"trigger" => trigger, "object" => object} = params) do
    object = Map.put(object, "trigger", trigger)
    %{params | "object" => object}
  end
end
