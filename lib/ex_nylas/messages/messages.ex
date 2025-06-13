defmodule ExNylas.Messages do
  @moduledoc """
  Interface for Nylas messages.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/messages)
  """

  alias ExNylas.API
  alias ExNylas.Response
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Message

  # Avoid conflict between Kernel.send/2 and __MODULE__.send/2
  import Kernel, except: [send: 2]

  use ExNylas,
    object: "messages",
    struct: Message,
    readable_name: "message",
    include: [:list, :first, :find, :update, :build, :all, :delete]

  @doc """
  Send a message.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  ## Examples

      iex> {:ok, sent_message} = ExNylas.Messages.send(conn, message, ["path_to_attachment"])
  """
  @spec send(Conn.t(), map(), list()) :: {:ok, Response.t()} | {:error, Response.t()}
  def send(%Conn{} = conn, message, attachments \\ []) do
    {body, content_type, len} = API.build_multipart(message, attachments)

    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/send",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": content_type, "content-length": to_string(len)]),
      body: body
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(Message)
  end

  @doc """
  Send a message.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  ## Examples

      iex> sent_message = ExNylas.Messages.send!(conn, message, ["path_to_attachment"])
  """
  @spec send!(Conn.t(), map(), list()) :: Response.t()
  def send!(%Conn{} = conn, message, attachments \\ []) do
    case send(conn, message, attachments) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Clean a message.

  ## Examples

      iex> {:ok, message} = ExNylas.Messages.clean(conn, payload)
  """
  @spec clean(Conn.t(), map()) :: {:ok, Response.t()} | {:error, Response.t()}
  def clean(%Conn{} = conn, payload) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/clean",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(),
      json: payload
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.put(conn.options)
    |> API.handle_response(Message)
  end

  @doc """
  Clean a message.

  ## Examples

      iex> message = ExNylas.Messages.clean!(conn, payload)
  """
  @spec clean!(Conn.t(), map()) :: Response.t()
  def clean!(%Conn{} = conn, payload) do
    case clean(conn, payload) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
