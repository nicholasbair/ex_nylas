defmodule ExNylas.WebhookNotification.ThreadReplied do
  @moduledoc """
  A struct representing a bounce detected webhook notification.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:label, :string)
    field(:message_id, :string)
    field(:root_message_id, :string)
    field(:sender_app_id, :string)
    field(:thread_id, :string)
    field(:timestamp, :integer) :: non_neg_integer()

    embeds_one :reply_data, ReplyData, primary_key: false do
      field(:count, :integer) :: non_neg_integer()
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message_id, :root_message_id, :label, :sender_app_id, :thread_id, :timestamp])
    |> cast_embed(:reply_data, with: &embedded_changeset/2)
  end
end
