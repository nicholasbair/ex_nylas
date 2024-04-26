defmodule ExNylas.WebhookNotification.MessageOpened do
  @moduledoc """
  A struct representing a message opened webhook notification.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  embedded_schema do
    field :message_id, :string
    field :label, :string
    field :sender_app_id, :string
    field :timestamp, :integer

    embeds_one :message_data, MessageData, primary_key: false do
      field :count, :integer
      field :timestamp, :integer
    end

    embeds_many :recents, Recent, primary_key: false do
      field :ip, :string
      field :opened_id, :integer
      field :timestamp, :integer
      field :user_agent, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message_id, :label, :sender_app_id, :timestamp])
    |> cast_embed(:message_data, with: &embedded_changeset/2)
    |> cast_embed(:recents, with: &embedded_changeset/2)
  end
end
