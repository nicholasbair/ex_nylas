defmodule ExNylas.Thread do
  @moduledoc """
  A struct representing a thread.
  """

  defstruct [
    :subject,
    :participants,
    :last_message_timestamp,
    :last_message_received_timestamp,
    :last_message_sent_timestamp,
    :first_message_timestamp,
    :snippet,
    :unread,
    :starred,
    :has_attachments,
    :version,
    :folders,
    :labels,
    :message_ids,
    :draft_ids,
    :messages,
    :drafts,
    :id,
    :object,
    :account_id,
  ]

  @typedoc "A thread"
  @type t :: %__MODULE__{
    subject: String.t(),
    participants: [ExNylas.Common.EmailParticipant.t()],
    last_message_timestamp: non_neg_integer(),
    last_message_received_timestamp: non_neg_integer(),
    last_message_sent_timestamp: non_neg_integer(),
    first_message_timestamp: non_neg_integer(),
    snippet: String.t(),
    unread: boolean(),
    starred: boolean(),
    has_attachments: boolean(),
    version: String.t(),
    folders: [ExNylas.Folder.t()],
    labels: [ExNylas.Label.t()],
    message_ids: [String.t()],
    draft_ids: [String.t()],
    messages: [ExNylas.Message.t()],
    drafts: [ExNylas.Draft.t()],
    id: String.t(),
    object: String.t(),
    account_id: String.t(),
  }

  def as_struct() do
    %ExNylas.Thread{
      participants: [ExNylas.Common.EmailParticipant.as_struct()],
      folders: [ExNylas.Folder.as_struct()],
      labels: [ExNylas.Label.as_struct()],
      messages: [ExNylas.Message.as_struct()],
      drafts: [ExNylas.Draft.as_struct()],
    }
  end

  def as_list(), do: [as_struct()]
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
