defmodule ExNylas.Thread do
  @moduledoc """
  A struct representing a thread.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A thread"
    field(:subject, String.t())
    field(:participants, list())
    field(:last_message_timestamp, non_neg_integer())
    field(:last_message_received_timestamp, non_neg_integer())
    field(:last_message_sent_timestamp, non_neg_integer())
    field(:first_message_timestamp, non_neg_integer())
    field(:snippet, String.t())
    field(:unread, boolean())
    field(:starred, boolean())
    field(:has_attachments, boolean())
    field(:version, String.t())
    field(:folders, list())
    field(:labels, list())
    field(:message_ids, list())
    field(:draft_ids, list())
    field(:messages, list())
    field(:drafts, list())
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
  end
end

defmodule ExNylas.Threads do
  @moduledoc """
  Interface for Nylas threads.
  """

  use ExNylas,
    object: "threads",
    struct: ExNylas.Thread,
    include: [:list, :first, :search, :find, :update, :all]
end
