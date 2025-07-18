defmodule ExNylas.Thread do
  @moduledoc """
  A struct representing a thread.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/threads)
  """

  alias ExNylas.{
    Draft,
    EmailParticipant,
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
          earliest_message_date: integer() | nil,
          latest_message_received_date: integer() | nil,
          latest_message_sent_date: integer() | nil,
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
    field(:draft_ids, {:array, :string})
    field(:earliest_message_date, :integer)
    field(:grant_id, :string)
    field(:has_attachments, :boolean)
    field(:has_drafts, :boolean)
    field(:id, :string)
    field(:latest_message_received_date, :integer)
    field(:latest_message_sent_date, :integer)
    field(:message_ids, {:array, :string})
    field(:object, :string)
    field(:snippet, :string)
    field(:starred, :boolean)
    field(:subject, :string)
    field(:unread, :boolean)

    polymorphic_embeds_one :latest_draft_or_message,
      types: [
        draft: Draft,
        message: Message
      ],
      type_field_name: :object,
      on_type_not_found: :changeset_error,
      on_replace: :update

    embeds_many :participants, EmailParticipant
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :grant_id, :id, :object, :has_attachments, :has_drafts, :earliest_message_date,
      :latest_message_received_date, :latest_message_sent_date, :snippet, :starred,
      :subject, :unread, :message_ids, :draft_ids
    ])
    |> cast_polymorphic_embed(:latest_draft_or_message)
    |> cast_embed(:participants)
  end
end
