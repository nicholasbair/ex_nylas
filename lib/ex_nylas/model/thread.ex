defmodule ExNylas.Model.Thread do
  @moduledoc """
  A struct representing a thread.
  """

  use TypedStruct
  alias ExNylas.Model.Common.EmailParticipant

  typedstruct do
    field(:grant_id, String.t())
    field(:id, String.t())
    field(:object, String.t())
    field(:has_attachments, boolean())
    field(:has_drafts, boolean())
    field(:earliest_message_timestamp, non_neg_integer())
    field(:last_message_received_at, non_neg_integer())
    field(:last_message_sent_at, non_neg_integer())
    field(:participants, [EmailParticipant.t()])
    field(:snippet, String.t())
    field(:starred, boolean())
    field(:subject, String.t())
    field(:unread, boolean())
    field(:message_ids, [String.t()])
    field(:draft_ids, [String.t()])
    field(:latest_draft_or_message, map())
  end

  def as_struct() do
    %__MODULE__{
      participants: [EmailParticipant.as_struct()],
    }
  end

  def as_list(), do: [as_struct()]
end
