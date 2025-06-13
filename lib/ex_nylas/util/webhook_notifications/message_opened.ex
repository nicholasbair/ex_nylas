defmodule ExNylas.WebhookNotification.MessageOpened do
  @moduledoc """
  A struct representing a message opened webhook notification.

  [Nylas docs](https://developer.nylas.com/docs/v3/notifications/notification-schemas/#message-tracking-notifications)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:label, :string)
    field(:grant_id, :string)
    field(:message_id, :string)
    field(:sender_app_id, :string)
    field(:timestamp, :integer) :: non_neg_integer()

    embeds_one :message_data, MessageData, primary_key: false do
      field(:count, :integer)
      field(:timestamp, :integer) :: non_neg_integer()
    end

    embeds_many :recents, Recent, primary_key: false do
      field(:ip, :string)
      field(:opened_id, :integer) :: non_neg_integer()
      field(:timestamp, :integer) :: non_neg_integer()
      field(:user_agent, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message_id, :label, :grant_id, :sender_app_id, :timestamp])
    |> cast_embed(:message_data, with: &embedded_changeset/2)
    |> cast_embed(:recents, with: &embedded_changeset/2)
  end
end
