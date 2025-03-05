defmodule ExNylas.Message do
  @moduledoc """
  A struct representing a message.
  """

  alias ExNylas.{
    Attachment,
    EmailParticipant,
    MessageHeader
  }

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:body, :string)
    field(:conversation, :string)
    field(:date, :integer) :: non_neg_integer() | nil
    field(:folders, {:array, :string})
    field(:grant_id, :string)
    field(:id, :string)
    field(:metadata, :map)
    field(:object, :string)
    field(:raw_mime, :string)
    field(:schedule_id, :string)
    field(:snippet, :string)
    field(:starred, :boolean)
    field(:subject, :string)
    field(:thread_id, :string)
    field(:unread, :boolean)

    embeds_many :attachments, Attachment
    embeds_many :bcc, EmailParticipant
    embeds_many :cc, EmailParticipant
    embeds_many :from, EmailParticipant
    embeds_many :headers, MessageHeader
    embeds_many :reply_to, EmailParticipant
    embeds_many :to, EmailParticipant
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :date, :folders, :grant_id, :id, :object, :snippet, :starred, :subject, :thread_id, :unread, :metadata, :schedule_id, :conversation, :raw_mime])
    |> cast_embed(:bcc)
    |> cast_embed(:cc)
    |> cast_embed(:attachments)
    |> cast_embed(:from)
    |> cast_embed(:reply_to)
    |> cast_embed(:to)
    |> cast_embed(:headers)
  end
end
