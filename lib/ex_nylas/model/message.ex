defmodule ExNylas.Model.Message do
  @moduledoc """
  A struct representing a message.
  """

  use TypedStruct

  alias ExNylas.Model.{
    Attachment,
    Common.EmailParticipant,
    Common.TrackingOptions,
    Common.MessageHeader
  }

  typedstruct do
    field(:bcc, [EmailParticipant.t()])
    field(:body, String.t())
    field(:cc, [EmailParticipant.t()])
    field(:date, non_neg_integer())
    field(:attachments, [Attachment.t()])
    field(:folders, [String.t()])
    field(:from, [EmailParticipant.t()])
    field(:grant_id, String.t())
    field(:id, String.t())
    field(:object, String.t())
    field(:reply_to, [EmailParticipant.t()])
    field(:reply_to_message_id, String.t())
    field(:snippet, String.t())
    field(:starred, boolean())
    field(:subject, String.t())
    field(:thread_id, String.t())
    field(:to, [EmailParticipant.t()])
    field(:unread, boolean())
    field(:metadata, map())
    field(:headers, [MessageHeader.t()])
    field(:schedule_id, String.t())
  end

  typedstruct module: Build do
    field(:bcc, list())
    field(:body, String.t())
    field(:cc, list())
    field(:attachments, list())
    field(:from, list())
    field(:reply_to, list())
    field(:reply_to_message_id, String.t())
    field(:subject, String.t())
    field(:to, list())
    field(:tracking_options, TrackingOptions.t())
    field(:metadata, map())
    field(:send_at, non_neg_integer())
    field(:use_draft, boolean())
  end

  def as_struct() do
    %__MODULE__{
      bcc: [EmailParticipant.as_struct()],
      cc: [EmailParticipant.as_struct()],
      attachments: [Attachment.as_struct()],
      from: [EmailParticipant.as_struct()],
      reply_to: [EmailParticipant.as_struct()],
      to: [EmailParticipant.as_struct()],
      headers: [MessageHeader.as_struct()],
    }
  end

  def as_list(), do: [as_struct()]
end
