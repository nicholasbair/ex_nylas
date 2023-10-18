defmodule ExNylas.Model.Draft do
  @moduledoc """
  A struct representing a draft.
  """

  use TypedStruct

  alias ExNylas.Model.{
    Attachment,
    Common.EmailParticipant,
    Common.TrackingOptions
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
  end

  typedstruct module: Build do
    field(:bcc, list())
    field(:body, String.t())
    field(:cc, list())
    field(:attachments, list())
    field(:from, list())
    field(:reply_to, list())
    field(:subject, String.t())
    field(:starred, boolean())
    field(:to, list())
    field(:tracking_options, TrackingOptions.t())
  end

  def as_struct() do
    %__MODULE__{
      bcc: [EmailParticipant.as_struct()],
      cc: [EmailParticipant.as_struct()],
      attachments: [Attachment.as_struct()],
      from: [EmailParticipant.as_struct()],
      reply_to: [EmailParticipant.as_struct()],
      to: [EmailParticipant.as_struct()],
    }
  end

  def as_list(), do: [as_struct()]
end
