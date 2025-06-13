defmodule ExNylas.Draft.Build do
  @moduledoc """
  Helper module for validating a draft before creating/updating it.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/drafts)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Attachment.Build, as: AttachmentBuild
  alias ExNylas.EmailParticipant.Build, as: EmailParticipantBuild
  alias ExNylas.MessageHeader.Build, as: MessageHeaderBuild
  alias ExNylas.TrackingOptions.Build, as: TrackingOptionsBuild

  @derive {Jason.Encoder, only: [:body, :subject, :reply_to_message_id, :metadata, :attachments, :bcc, :cc, :custom_headers, :from, :reply_to, :to, :tracking_options]}
  @primary_key false

  typed_embedded_schema do
    field(:body, :string)
    field(:subject, :string)
    field(:reply_to_message_id, :string)
    field(:metadata, :map)

    embeds_many :attachments, AttachmentBuild
    embeds_many :bcc, EmailParticipantBuild
    embeds_many :cc, EmailParticipantBuild
    embeds_many :custom_headers, MessageHeaderBuild
    embeds_many :from, EmailParticipantBuild
    embeds_many :reply_to, EmailParticipantBuild
    embeds_many :to, EmailParticipantBuild
    embeds_one :tracking_options, TrackingOptionsBuild
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:reply_to_message_id, :subject, :body, :metadata])
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
