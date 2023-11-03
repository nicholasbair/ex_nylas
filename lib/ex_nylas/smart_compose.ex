defmodule ExNylas.SmartCompose do
  @moduledoc """
  Interface for Nylas smart compose.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  use ExNylas,
    object: "messages/smart-compose",
    struct: ExNylas.Model.SmartCompose,
    readable_name: "smart compose",
    include: [:build, :create]

  @doc """
  Smart compose a message reply.

  Example
      {:ok, res} = conn |> ExNylas.SmartCompose.create_reply(`message_id`, `prompt`)
  """
  def create_reply(%Conn{} = conn, message_id, prompt) do
    API.post(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/#{message_id}/smart-compose",
      %{prompt: prompt},
      API.header_bearer(conn) ++ ["content-type": "application/json"],
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.SmartCompose.as_struct())
  end

  @doc """
  Smart compose a message reply.

  Example
      res = conn |> ExNylas.SmartCompose.create_reply!(`message_id`, `prompt`)
  """
  def create_reply!(%Conn{} = conn, message_id, prompt) do
    case create_reply(conn, message_id, prompt) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Smart compose a message with a streaming response.

  Note - the response is a stream of untransformed events as shown in the example below.

  Example
      {:ok, %HTTPoison.AsyncResponse{id: #Reference<0.1234>}} = conn |> ExNylas.SmartCompose.create_stream(`prompt`, `self()`)
      iex> flush
      %HTTPoison.AsyncStatus{id: #Reference<0.1234>, code: 200}
      %HTTPoison.AsyncHeaders{
        id: #Reference<0.1234>,
        headers: [
          {"Content-Type", "text/event-stream; charset=utf-8"},
          {"Transfer-Encoding", "chunked"}
        ]
      }
      %HTTPoison.AsyncChunk{id: #Reference<0.1234>, chunk: "data: {\"suggestion\":\"Hello\"}\n\n"}
      %HTTPoison.AsyncEnd{id: #Reference<0.1234>}
  """
  def create_stream(%Conn{} = conn, prompt, stream_to) do
    API.post(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/smart-compose",
      %{prompt: prompt},
      API.header_bearer(conn) ++ ["content-type": "application/json"] |> Keyword.replace(:accept, "text/event-stream"),
      [
        timeout: conn.timeout,
        recv_timeout: conn.recv_timeout,
        stream_to: stream_to
      ]
    )
    |> API.handle_response(nil, false)
  end

  @doc """
  Smart compose a reply to a message with a streaming response.

  Note - the response is a stream of untransformed events as shown in the example below.

  Example
      {:ok, %HTTPoison.AsyncResponse{id: #Reference<0.1234>}} = conn |> ExNylas.SmartCompose.create_reply_stream(`message_id`, `prompt`, `self()`)
      iex> flush
      %HTTPoison.AsyncStatus{id: #Reference<0.1234>, code: 200}
      %HTTPoison.AsyncHeaders{
        id: #Reference<0.1234>,
        headers: [
          {"Content-Type", "text/event-stream; charset=utf-8"},
          {"Transfer-Encoding", "chunked"}
        ]
      }
      %HTTPoison.AsyncChunk{id: #Reference<0.1234>, chunk: "data: {\"suggestion\":\"Hello\"}\n\n"}
      %HTTPoison.AsyncEnd{id: #Reference<0.1234>}
  """
  def create_reply_stream(%Conn{} = conn, message_id, prompt, stream_to) do
    API.post(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/#{message_id}/smart-compose",
      %{prompt: prompt},
      API.header_bearer(conn) ++ ["content-type": "application/json"] |> Keyword.replace(:accept, "text/event-stream"),
      [
        timeout: conn.timeout,
        recv_timeout: conn.recv_timeout,
        stream_to: stream_to
      ]
    )
    |> API.handle_response(nil, false)
  end
end
