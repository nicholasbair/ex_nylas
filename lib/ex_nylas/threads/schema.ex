defmodule ExNylas.Schema.Thread do
  @moduledoc """
  A struct representing a thread.
  """

  alias ExNylas.Schema.Common.EmailParticipant

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "thread" do
    field :grant_id, :string
    field :id, :string
    field :object, :string
    field :has_attachments, :boolean
    field :has_drafts, :boolean
    field :earliest_message_timestamp, :integer
    field :last_message_received_at, :integer
    field :last_message_sent_at, :integer
    field :snippet, :string
    field :starred, :boolean
    field :subject, :string
    field :unread, :boolean
    field :message_ids, {:array, :string}
    field :draft_ids, {:array, :string}
    field :latest_draft_or_message, :map

    embeds_many :participants, EmailParticipant
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:grant_id, :id, :object, :has_attachments, :has_drafts, :earliest_message_timestamp, :last_message_received_at, :last_message_sent_at, :snippet, :starred, :subject, :unread, :message_ids, :draft_ids, :latest_draft_or_message])
    |> cast_embed(:participants)
    |> validate_required([:id, :grant_id])
  end
end
