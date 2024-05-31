defmodule ExNylas.Message.Build do
  @moduledoc """
  Helper module for validating a message before sending it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Common.{
    Build.Attachment,
    EmailParticipant,
    TrackingOptions,
    MessageHeader
  }

  @derive {Jason.Encoder, only: [:body, :reply_to_message_id, :subject, :metadata, :send_at, :use_draft, :attachments, :bcc, :cc, :from, :reply_to, :to, :tracking_options]}
  @primary_key false

  typed_embedded_schema do
    field(:body, :string)
    field(:reply_to_message_id, :string)
    field(:subject, :string)
    field(:metadata, :map)
    field(:send_at, :integer) :: non_neg_integer() | nil
    field(:use_draft, :boolean)

    embeds_many :attachments, Attachment
    embeds_many :bcc, EmailParticipant
    embeds_many :cc, EmailParticipant
    embeds_many :from, EmailParticipant
    embeds_many :reply_to, EmailParticipant
    embeds_many :to, EmailParticipant
    embeds_many :custom_headers, MessageHeader
    embeds_one :tracking_options, TrackingOptions
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :reply_to_message_id, :subject, :metadata, :send_at, :use_draft])
    |> cast_embed(:attachments)
    |> cast_embed(:from)
    |> cast_embed(:to, required: true)
    |> cast_embed(:cc)
    |> cast_embed(:bcc)
    |> cast_embed(:tracking_options)
    |> cast_embed(:reply_to)
    |> cast_embed(:custom_headers)
    |> validate_required([:subject])
  end
end
