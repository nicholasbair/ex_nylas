defmodule ExNylas.Messages do
  @moduledoc """
  Interface for Nylas messages.
  """

  alias ExNylas.API
  alias ExNylas.Common
  alias ExNylas.Connection, as: Conn

  # Avoid conflict between Kernel.send/2 and __MODULE__.send/2
  import Kernel, except: [send: 2]

  use ExNylas,
    object: "messages",
    struct: ExNylas.Model.Message,
    include: [:list, :first, :search, :find, :update, :build, :all]

  @doc """
  Send a message.

  Example
      {:ok, sent_message} = conn |> ExNylas.Messages.send(`message`, `["path_to_attachment"]`)
  """
  def send(%Conn{} = conn, message, attachments \\ []) do
    API.post(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/send",
      Common.build_multipart_body(message, attachments),
      API.header_bearer(conn) ++ ["content-type": "multipart/form-data"],
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.Message.as_struct())
  end

  @doc """
  Send a message.

  Example
      sent_message = conn |> ExNylas.Messages.send!(`message`, `["path_to_attachment"]`)
  """
  def send!(%Conn{} = conn, message, attachments \\ []) do
    case send(conn, message, attachments) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
