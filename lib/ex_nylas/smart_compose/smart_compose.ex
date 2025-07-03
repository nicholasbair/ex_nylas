defmodule ExNylas.SmartCompose do
  @moduledoc """
  Interface for Nylas smart compose.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/smart-compose)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    Response,
    ResponseHandler,
    Telemetry
  }

  alias ExNylas.Schema.SmartCompose, as: SC

  @doc """
  Create a smart compose.

  ## Examples

      iex> {:ok, res} = ExNylas.SmartCompose.create(conn, prompt)
  """
  @spec create(Connection.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def create(%Connection{} = conn, prompt) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/smart-compose",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{prompt: prompt}
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(SC)
  end

  @doc """
  Create a smart compose.

  ## Examples

      iex> res = ExNylas.SmartCompose.create!(conn, prompt)
  """
  @spec create!(Connection.t(), String.t()) :: Response.t()
  def create!(%Connection{} = conn, prompt) do
    case create(conn, prompt) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Smart compose a message reply.

  ## Examples

      iex> {:ok, res} = ExNylas.SmartCompose.create_reply(conn, message_id, prompt)
  """
  @spec create_reply(Connection.t(), String.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def create_reply(%Connection{} = conn, message_id, prompt) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/#{message_id}/smart-compose",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(),
      json: %{prompt: prompt}
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(SC)
  end

  @doc """
  Smart compose a message reply.

  ## Examples

      iex> res = ExNylas.SmartCompose.create_reply!(conn, message_id, prompt)
  """
  @spec create_reply!(Connection.t(), String.t(), String.t()) :: Response.t()
  def create_reply!(%Connection{} = conn, message_id, prompt) do
    case create_reply(conn, message_id, prompt) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Smart compose a message with a streaming response.

  Note - ExNylas will call the provided function with each transformed chunk of the suggestion as it is received.

  ## Examples

      iex> ExNylas.SmartCompose.create_stream(conn, prompt, &IO.write/1)
      iex> Dear [Recipient], ...
      iex> {:ok, ""}
  """
  @spec create_stream(Connection.t(), String.t(), function()) :: {:ok, Response.t()} | {:error, Response.t()}
  def create_stream(%Connection{} = conn, prompt, stream_to) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/smart-compose",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers([accept: "text/event-stream"]),
      json: %{prompt: prompt},
      decode_body: false,
      into: ResponseHandler.handle_stream(stream_to),
      compressed: false
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response()
  end

  @doc """
  Smart compose a reply to a message with a streaming response.

  Note - ExNylas will call the provided function with each transformed chunk of the suggestion as it is received.

  ## Examples

      iex> ExNylas.SmartCompose.create_reply_stream(conn, message_id, prompt, &IO.write/1)
      iex> Dear [Recipient], ...
      iex> {:ok, ""}
  """
    @spec create_reply_stream(Connection.t(), String.t(), String.t(), function()) ::
    {:ok, Response.t()} | {:error, Response.t()}
  def create_reply_stream(%Connection{} = conn, message_id, prompt, stream_to) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/#{message_id}/smart-compose",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers([accept: "text/event-stream"]),
      json: %{prompt: prompt},
      decode_body: false,
      into: ResponseHandler.handle_stream(stream_to),
      compressed: false
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response()
  end
end
