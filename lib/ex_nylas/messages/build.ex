defmodule ExNylas.Message.Build do
  @moduledoc """
  Helper module for validating a message before sending it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Attachment.Build, as: AttachmentBuild
  alias ExNylas.EmailParticipant.Build, as: EmailParticipantBuild
  alias ExNylas.MessageHeader.Build, as: MessageHeaderBuild
  alias ExNylas.TrackingOptions.Build, as: TrackingOptionsBuild

  @derive {Jason.Encoder, only: [:body, :reply_to_message_id, :subject, :metadata, :send_at, :use_draft, :attachments, :bcc, :cc, :custom_headers, :from, :reply_to, :to, :tracking_options]}
  @primary_key false

  typed_embedded_schema do
    field(:body, :string)
    field(:metadata, :map)
    field(:reply_to_message_id, :string)
    field(:subject, :string)
    field(:send_at, :integer) :: non_neg_integer() | nil
    field(:use_draft, :boolean)

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
