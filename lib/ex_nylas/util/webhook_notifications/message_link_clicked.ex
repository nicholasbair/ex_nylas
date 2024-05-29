defmodule ExNylas.WebhookNotification.MessageLinkClicked do
  @moduledoc """
  A struct representing a link clicked webhook notification.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field :message_id, :string
    field :label, :string
    field :sender_app_id, :string
    field :timestamp, :integer

    embeds_one :link_data, LinkData, primary_key: false do
      field :count, :integer
      field :url, :string
    end

    embeds_many :recents, Recent, primary_key: false do
      field :click_id, :string
      field :ip, :string
      field :link_index, :string
      field :timestamp, :integer
      field :user_agent, :string
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message_id, :label, :sender_app_id, :timestamp])
    |> cast_embed(:link_data, with: &embedded_changeset/2)
    |> cast_embed(:recents, with: &embedded_changeset/2)
  end
end
