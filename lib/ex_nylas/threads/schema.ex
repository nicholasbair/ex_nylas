defmodule ExNylas.Thread do
  @moduledoc """
  A struct representing a thread.
  """

  alias ExNylas.{
    EmailParticipant,
    Draft,
    Message
  }

  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  # TypedEctoSchema and PolymorphicEmbed don't play nice together, so explicitly define the type
  @type t :: %__MODULE__{
          grant_id: String.t() | nil,
          id: String.t() | nil,
          object: String.t() | nil,
          has_attachments: boolean() | nil,
          has_drafts: boolean() | nil,
          earliest_message_timestamp: integer() | nil,
          last_message_received_at: integer() | nil,
          last_message_sent_at: integer() | nil,
          snippet: String.t() | nil,
          starred: boolean() | nil,
          subject: String.t() | nil,
          unread: boolean() | nil,
          message_ids: [String.t()] | nil,
          draft_ids: [String.t()] | nil,
          latest_draft_or_message: Draft.t() | Message.t() | nil,
          participants: [EmailParticipant.t()] | nil
        }

  @primary_key false

  embedded_schema do
    field :draft_ids, {:array, :string}
    field :earliest_message_timestamp, :integer
    field :grant_id, :string
    field :has_attachments, :boolean
    field :has_drafts, :boolean
    field :id, :string
    field :last_message_received_at, :integer
    field :last_message_sent_at, :integer
    field :message_ids, {:array, :string}
    field :object, :string
    field :snippet, :string
    field :starred, :boolean
    field :subject, :string
    field :unread, :boolean

    polymorphic_embeds_one :latest_draft_or_message,
      types: [
        draft: Draft,
        message: Message
      ],
      type_field: "object",
      on_type_not_found: :changeset_error,
      on_replace: :update

    embeds_many :participants, EmailParticipant
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:grant_id, :id, :object, :has_attachments, :has_drafts, :earliest_message_timestamp, :last_message_received_at, :last_message_sent_at, :snippet, :starred, :subject, :unread, :message_ids, :draft_ids])
    |> cast_polymorphic_embed(:latest_draft_or_message, required: true)
    |> cast_embed(:participants)
  end
end
