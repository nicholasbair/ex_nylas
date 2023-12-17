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
    struct: ExNylas.Model.Message,
    readable_name: "message",
    include: [:list, :first, :search, :find, :update, :build, :all]

  @doc """
  Send a message.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  ## Examples

      iex> {:ok, sent_message} = ExNylas.Messages.send(conn, message, ["path_to_attachment"])
  """
  def send(%Conn{} = conn, message, attachments \\ []) do
    {body, content_type, len} = API.build_multipart(message, attachments)

    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/send",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": content_type, "content-length": to_string(len)]),
      body: body,
      decode_body: false
    )
    |> Req.post(conn.options)
    |> API.handle_response(ExNylas.Model.Message.as_struct())
  end

  @doc """
  Send a message.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  ## Examples

      iex> sent_message = ExNylas.Messages.send!(conn, message, ["path_to_attachment"])
  """
  def send!(%Conn{} = conn, message, attachments \\ []) do
    case send(conn, message, attachments) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
