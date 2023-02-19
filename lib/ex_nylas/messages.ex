defmodule ExNylas.Message do
  @moduledoc """
  A struct representing a message.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A message"
    field(:account_id, String.t())
    field(:bcc, list())
    field(:body, String.t())
    field(:cc, list())
    field(:date, non_neg_integer())
    field(:events, list())
    field(:files, list())
    field(:folder, map())
    field(:from, list())
    field(:id, String.t())
    field(:labels, list())
    field(:object, String.t())
    field(:reply_to, list())
    field(:snippet, String.t())
    field(:starred, boolean())
    field(:subject, String.t())
    field(:thread_id, String.t())
    field(:to, list())
    field(:unread, boolean())
    field(:reply_to_message_id, String.t())
    field(:metadata, map())
    field(:cids, list())
    field(:headers, map())
  end

  typedstruct module: Build do
    @typedoc "A struct representing the send message request payload."
    field(:bcc, list())
    field(:body, String.t())
    field(:cc, list())
    field(:events, list())
    field(:files, list())
    field(:from, list())
    field(:labels, list())
    field(:reply_to, list())
    field(:subject, String.t())
    field(:to, list())
    field(:tracking, map())
    field(:metadata, map())
  end
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
