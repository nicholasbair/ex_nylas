defmodule ExNylas.Draft do
  @moduledoc """
  A struct representing a draft.
  """

  defstruct [
    :id,
    :object,
    :account_id,
    :subject,
    :from,
    :reply_to,
    :to,
    :cc,
    :bcc,
    :date,
    :thread_id,
    :snippet,
    :body,
    :unread,
    :starred,
    :files,
    :events,
    :labels,
    :version,
    :job_status_id,
    :reply_to_message_id,
    :folder,
    :metadata,
    :cids,
  ]

  @typedoc "A draft"
  @type t :: %__MODULE__{
    id: String.t(),
    object: String.t(),
    account_id: String.t(),
    subject: String.t(),
    from: [ExNylas.Common.EmailParticipant.t()],
    reply_to: [ExNylas.Common.EmailParticipant.t()],
    to: [ExNylas.Common.EmailParticipant.t()],
    cc: [ExNylas.Common.EmailParticipant.t()],
    bcc: [ExNylas.Common.EmailParticipant.t()],
    date: non_neg_integer(),
    thread_id: String.t(),
    snippet: String.t(),
    body: String.t(),
    unread: boolean(),
    starred: boolean(),
    files: [ExNylas.File.t()],
    events: [ExNylas.Event.t()],
    labels: [ExNylas.Label.t()],
    version: non_neg_integer(),
    job_status_id: String.t(),
    reply_to_message_id: String.t(),
    folder: ExNylas.Folder.t(),
    metadata: map(),
    cids: [String.t()],
  }

  def as_struct, do: %ExNylas.Draft{
    from: [ExNylas.Common.EmailParticipant.as_struct()],
    reply_to: [ExNylas.Common.EmailParticipant.as_struct()],
    to: [ExNylas.Common.EmailParticipant.as_struct()],
    cc: [ExNylas.Common.EmailParticipant.as_struct()],
    bcc: [ExNylas.Common.EmailParticipant.as_struct()],
    files: [ExNylas.File.as_struct()],
    events: [ExNylas.Event.as_struct()],
    labels: [ExNylas.Label.as_struct()],
  }

  def as_list, do: [as_struct()]

  defmodule Build do
    defstruct [
      :subject,
      :to,
      :cc,
      :bcc,
      :from,
      :reply_to,
      :reply_to_message_id,
      :file_ids,
      :body,
      :metadata,
    ]

    @typedoc "A struct representing the create draft request payload."
    @type t :: %__MODULE__{
      subject: String.t(),
      from: [ExNylas.Common.EmailParticipant.t()],
      reply_to: [ExNylas.Common.EmailParticipant.t()],
      to: [ExNylas.Common.EmailParticipant.t()],
      cc: [ExNylas.Common.EmailParticipant.t()],
      bcc: [ExNylas.Common.EmailParticipant.t()],
      reply_to_message_id: String.t(),
      file_ids: [String.t()],
      body: String.t(),
      metadata: map(),
    }
  end
end

defmodule ExNylas.Drafts do
  @moduledoc """
  Interface for Nylas Drafts.
  """
  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  use ExNylas,
    object: "drafts",
    struct: ExNylas.Draft,
    include: [:list, :first, :find, :delete, :build, :create, :update, :all]

  @doc """
  Send a draft.

  Example
      {:ok, sent_message} = conn |> ExNylas.Drafts.send(`draft_id`, `version`)
  """
  def send(%Conn{} = conn, draft_id, version, tracking \\ %{}) do
    API.post(
      "#{conn.api_server}/send",
      %{
        draft_id: draft_id,
        version: version,
        tracking: tracking
      },
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Message)
  end

  @doc """
  Send a draft.

  Example
      sent_message = conn |> ExNylas.Drafts.send!(`draft_id`, `version`)
  """
  def send!(%Conn{} = conn, draft_id, version, tracking \\ %{}) do
    case send(conn, draft_id, version, tracking) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
