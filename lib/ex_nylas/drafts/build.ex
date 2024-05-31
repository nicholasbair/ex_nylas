defmodule ExNylas.Draft.Build do
  @moduledoc """
  Helper module for validating a draft before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Common.{
    Build.Attachment,
    EmailParticipant,
    TrackingOptions,
    MessageHeader
  }

  @derive {Jason.Encoder, only: [:reply_to_message_id, :subject, :body, :attachments, :bcc, :cc, :from, :reply_to, :to, :tracking_options]}
  @primary_key false

  typed_embedded_schema do
    field(:reply_to_message_id, :string)
    field(:subject, :string)
    field(:body, :string)

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
    |> cast(params, [:reply_to_message_id, :subject, :body])
    |> cast_embed(:attachments)
    |> cast_embed(:from)
    |> cast_embed(:to)
    |> cast_embed(:cc)
    |> cast_embed(:bcc)
    |> cast_embed(:tracking_options)
    |> cast_embed(:reply_to)
    |> cast_embed(:custom_headers)
  end
end
