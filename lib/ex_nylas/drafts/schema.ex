defmodule ExNylas.Draft do
  @moduledoc """
  A struct representing a draft.
  """

  alias ExNylas.{
    Attachment,
    Common.EmailParticipant,
    Common.TrackingOptions
  }

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string, null: false)
    field(:grant_id, :string, null: false)
    field(:object, :string, null: false)
    field(:thread_id, :string)
    field(:reply_to_message_id, :string)
    field(:date, :integer) :: non_neg_integer()
    field(:snippet, :string)
    field(:starred, :boolean)
    field(:subject, :string)
    field(:body, :string)
    field(:folders, {:array, :string}, null: false)

    embeds_many :attachments, Attachment
    embeds_many :bcc, EmailParticipant
    embeds_many :cc, EmailParticipant
    embeds_many :from, EmailParticipant
    embeds_many :reply_to, EmailParticipant
    embeds_many :to, EmailParticipant
    embeds_one :tracking_options, TrackingOptions
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :grant_id, :object, :thread_id, :reply_to_message_id, :date, :snippet, :starred, :subject, :body, :folders])
    |> cast_embed(:attachments)
    |> cast_embed(:from)
    |> cast_embed(:to)
    |> cast_embed(:cc)
    |> cast_embed(:bcc)
    |> cast_embed(:tracking_options)
    |> cast_embed(:reply_to)
    |> validate_required([:id, :grant_id])
  end
end
