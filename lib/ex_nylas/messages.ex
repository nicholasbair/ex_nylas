defmodule ExNylas.Message do
  @moduledoc """
  A struct representing a message.
  """

  defstruct [
    :account_id,
    :bcc,
    :body,
    :cc,
    :date,
    :events,
    :files,
    :folder,
    :from,
    :id,
    :labels,
    :object,
    :reply_to,
    :snippet,
    :starred,
    :subject,
    :thread_id,
    :to,
    :unread,
    :reply_to_message_id,
    :metadata,
    :cids,
    :headers,
  ]

  @typedoc "A message"
  @type t :: %__MODULE__{
    account_id: String.t(),
    bcc: [ExNylas.Common.EmailParticipant.t()],
    body: String.t(),
    cc: [ExNylas.Common.EmailParticipant.t()],
    date: non_neg_integer(),
    events: [ExNylas.Event.t()],
    files: [ExNylas.File.t()],
    folder: ExNylas.Folder.t(),
    from: [ExNylas.Common.EmailParticipant.t()],
    id: String.t(),
    labels: [ExNylas.Label.t()],
    object: String.t(),
    reply_to: [ExNylas.Common.EmailParticipant.t()],
    snippet: String.t(),
    starred: boolean(),
    subject: String.t(),
    thread_id: String.t(),
    to: [ExNylas.Common.EmailParticipant.t()],
    unread: boolean(),
    reply_to_message_id: String.t(),
    metadata: map(),
    cids: [String.t()],
    headers: ExNylas.Headers.t(),
  }

  defmodule Headers do
    defstruct [
      :"In-Reply-To",
      :"Message-Id",
      :References,
    ]

    @type t :: %__MODULE__{
      "In-Reply-To": String.t(),
      "Message-Id": String.t(),
      References: [String.t()],
    }

    def as_struct() do
      %ExNylas.Message.Headers{}
    end
  end

  defmodule Build do
    defstruct [
      :bcc,
      :body,
      :cc,
      :events,
      :files,
      :from,
      :labels,
      :reply_to,
      :subject,
      :to,
      :tracking,
      :metadata,
    ]

    @typedoc "A struct representing the send message request payload."
    @type t :: %__MODULE__{
      bcc: list(),
      body: String.t(),
      cc: list(),
      events: list(),
      files: list(),
      from: list(),
      labels: list(),
      reply_to: list(),
      subject: String.t(),
      to: list(),
      tracking: map(),
      metadata: map(),
    }
  end

  def as_struct() do
    %ExNylas.Message{
      bcc: [ExNylas.Common.EmailParticipant.as_struct()],
      cc: [ExNylas.Common.EmailParticipant.as_struct()],
      events: [ExNylas.Event.as_struct()],
      files: [ExNylas.File.as_struct()],
      folder: ExNylas.Folder.as_struct(),
      from: [ExNylas.Common.EmailParticipant.as_struct()],
      labels: [ExNylas.Label.as_struct()],
      reply_to: [ExNylas.Common.EmailParticipant.as_struct()],
      to: [ExNylas.Common.EmailParticipant.as_struct()],
      headers: ExNylas.Message.Headers.as_struct(),
    }
  end

  def as_list(), do: [as_struct()]
end

defmodule ExNylas.Messages do
  @moduledoc """
  Interface for Nylas messages.
  """
  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  # Avoid conflict between Kernel.send/2 and __MODULE__.send/2
  import Kernel, except: [send: 2]

  use ExNylas,
    object: "messages",
    struct: ExNylas.Message,
    include: [:list, :first, :search, :find, :update, :build, :all]

  @doc """
  Get the raw content for a message.

  Example
      {:ok, raw} = conn |> ExNylas.Messages.get_raw(`id`)
  """
  def get_raw(%Conn{} = conn, id) do
    headers =
      conn
      |> API.header_bearer()
      |> Keyword.put(:accept, "message/rfc822")

    API.get("#{conn.api_server}/messages/#{id}", headers)
    |> API.handle_response()
  end

  @doc """
  Get the raw content for a message.

  Example
      raw = conn |> ExNylas.Messages.get_raw!(`id`)
  """
  def get_raw!(%Conn{} = conn, id) do
    case get_raw(conn, id) do
      {:ok, message} -> message
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send a message using raw mime.

  Example
      {:ok, sent_message} = conn |> ExNylas.Messages.send_raw(`raw`)
  """
  def send_raw(%Conn{} = conn, raw) do
    API.post(
      "#{conn.api_server}/send",
      raw,
      API.header_bearer(conn) ++ ["content-type": "message/rfc822"]
    )
    |> API.handle_response(ExNylas.Message)
  end

  @doc """
  Send a message using raw mime.

  Example
      sent_message = conn |> ExNylas.Messages.send_raw!(`raw`)
  """
  def send_raw!(%Conn{} = conn, raw) do
    case send(conn, raw) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send a message.

  Example
      {:ok, sent_message} = conn |> ExNylas.Messages.send(`message`)
  """
  def send(%Conn{} = conn, message) do
    API.post(
      "#{conn.api_server}/send",
      message,
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Message)
  end

  @doc """
  Send a message.

  Example
      sent_message = conn |> ExNylas.Messages.send!(`message`)
  """
  def send!(%Conn{} = conn, message) do
    case send(conn, message) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
