defmodule ExNylas.Message.Build do
  @moduledoc """
  Helper module for validating a message before sending it.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.{
    Build.Attachment,
    EmailParticipant,
    TrackingOptions,
    MessageHeader
  }

  @type t :: %__MODULE__{
          body: String.t(),
          reply_to_message_id: String.t(),
          subject: String.t(),
          metadata: map(),
          send_at: integer(),
          use_draft: boolean(),
          attachments: list(Attachment.t()),
          bcc: list(EmailParticipant.t()),
          cc: list(EmailParticipant.t()),
          from: list(EmailParticipant.t()),
          reply_to: list(EmailParticipant.t()),
          to: list(EmailParticipant.t()),
          custom_headers: list(MessageHeader.t()),
          tracking_options: TrackingOptions.t()
        }

  @derive {Jason.Encoder, only: [:body, :reply_to_message_id, :subject, :metadata, :send_at, :use_draft, :attachments, :bcc, :cc, :from, :reply_to, :to, :tracking_options]}
  @primary_key false

  embedded_schema do
    field :body, :string
    field :reply_to_message_id, :string
    field :subject, :string
    field :metadata, :map
    field :send_at, :integer
    field :use_draft, :boolean

    embeds_many :attachments, Attachment
    embeds_many :bcc, EmailParticipant
    embeds_many :cc, EmailParticipant
    embeds_many :from, EmailParticipant
    embeds_many :reply_to, EmailParticipant
    embeds_many :to, EmailParticipant
    embeds_many :custom_headers, MessageHeader
    embeds_one :tracking_options, TrackingOptions
  end

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
