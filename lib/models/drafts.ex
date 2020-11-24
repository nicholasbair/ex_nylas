defmodule ExNylas.Draft do
  @moduledoc """
  A struct representing a draft.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A draft"
    field :id,                  String.t()
    field :object,              String.t()
    field :account_id,          String.t()
    field :subject,             String.t()
    field :from,                list()
    field :reply_to,            list()
    field :to,                  list()
    field :cc,                  list()
    field :bcc,                 list()
    field :date,                non_neg_integer()
    field :thread_id,           String.t()
    field :snippet,             String.t()
    field :body,                String.t()
    field :unread,              boolean()
    field :starred,             boolean()
    field :files,               list()
    field :events,              list()
    field :labels,              list()
    field :version,             String.t()
    field :reply_to_message_id, String.t()
  end

end

defmodule ExNylas.Draft.Build do
  @moduledoc """
  A struct representing a draft.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A draft"
    field :subject,             String.t()
    field :to,                  list()
    field :cc,                  list()
    field :bcc,                 list()
    field :from,                list()
    field :reply_to,            list()
    field :reply_to_message_id, String.t()
    field :file_ids,            list()
  end

end

defmodule ExNylas.Drafts do
  @moduledoc """
  Interface for Nylas Drafts.
  """

  # Avoid conflict between Kernel.send/2 and __MODULE__.send/2
  import Kernel, except: [send: 2]

  use ExNylas, object: "drafts", struct: ExNylas.Draft, except: [:search]

end
