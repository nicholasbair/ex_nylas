defmodule ExNylas.Draft do
  @moduledoc """
  A struct representing a draft.
  """

  alias ExNylas.{
    Attachment,
    Common.EmailParticipant,
    Common.TrackingOptions
  }

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :id, :string
    field :grant_id, :string
    field :object, :string
    field :thread_id, :string
    field :reply_to_message_id, :string
    field :date, :integer
    field :snippet, :string
    field :starred, :boolean
    field :subject, :string
    field :body, :string
    field :folders, {:array, :string}

    embeds_many :attachments, Attachment
    embeds_many :bcc, EmailParticipant
    embeds_many :cc, EmailParticipant
    embeds_many :from, EmailParticipant
    embeds_many :reply_to, EmailParticipant
    embeds_many :to, EmailParticipant
    embeds_one :tracking_options, TrackingOptions
  end

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
