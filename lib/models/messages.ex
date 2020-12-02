defmodule ExNylas.Message do
  @moduledoc """
  A struct representing a message.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A message"
    field :account_id, String.t()
    field :bcc,        list()
    field :body,       String.t()
    field :cc,         list()
    field :date,       non_neg_integer()
    field :events,     list()
    field :files,      list()
    field :from,       list()
    field :id,         String.t()
    field :labels,     list()
    field :object,     String.t()
    field :reply_to,   list()
    field :snippet,    String.t()
    field :starred,    boolean()
    field :subject,    String.t()
    field :thread_id,  String.t()
    field :to,         list()
    field :unread,     boolean()
  end

end

defmodule ExNylas.Messages do
  @moduledoc """
  Interface for Nylas messages.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @object "messages"

  use ExNylas,
    object: @object,
    struct: ExNylas.Message,
    include: [:list, :first, :search, :find, :update]

  @doc """
  Get the raw content for a message.

  Example
      {:ok, raw} = conn |> ExNylas.Messages.get_raw(`id`)
  """
  def get_raw(%Conn{} = conn, id) do
    headers = API.header_bearer(conn) ++ [accept: "message/rfc822"]
    res = API.get("#{conn.api_server}/#{@object}/#{id}", headers)

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
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

end
