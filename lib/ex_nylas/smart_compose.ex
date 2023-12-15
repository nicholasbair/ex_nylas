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
      {:ok, res} = ExNylas.SmartCompose.create_reply(conn, `message_id`, `prompt`)
  """
  def create_reply(%Conn{} = conn, message_id, prompt) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/#{message_id}/smart-compose",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: %{prompt: prompt},
      decode_body: false
    )
    |> Req.post(conn.options)
    |> API.handle_response(ExNylas.Model.SmartCompose.as_struct())
  end

  @doc """
  Smart compose a message reply.

  Example
      res = ExNylas.SmartCompose.create_reply!(conn, `message_id`, `prompt`)
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
      ExNylas.SmartCompose.create_stream(conn, `prompt`, `IO.stream()`)
      data: {"suggestion": ""}
      data: {"suggestion": "Subject"}
      ...
      data: {"suggestion": "]"}
      {:ok, %IO.Stream{device: :standard_io, raw: false, line_or_bytes: :line}}
  """
  def create_stream(%Conn{} = conn, prompt, stream_to) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/smart-compose",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"] |> Keyword.replace(:accept, "text/event-stream")),
      json: %{prompt: prompt},
      decode_body: false,
      into: stream_to
    )
    |> Req.post(conn.options)
    |> API.handle_response(nil, false)
  end

  @doc """
  Smart compose a reply to a message with a streaming response.

  Note - the response is a stream of untransformed events as shown in the example below.

  Example
      ExNylas.SmartCompose.create_stream(conn, `message_id`, `prompt`, `IO.stream()`)
      data: {"suggestion": ""}
      data: {"suggestion": "Subject"}
      ...
      data: {"suggestion": "]"}
      {:ok, %IO.Stream{device: :standard_io, raw: false, line_or_bytes: :line}}
  """
  def create_reply_stream(%Conn{} = conn, message_id, prompt, stream_to) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/#{message_id}/smart-compose",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: %{prompt: prompt},
      decode_body: false,
      into: stream_to
    )
    |> Req.post(conn.options)
    |> API.handle_response(nil, false)
  end
end
