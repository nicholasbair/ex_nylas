defmodule ExNylas.Messages do
  @moduledoc """
  Interface for Nylas messages.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/messages)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    Message,
    Multipart,
    Response,
    ResponseHandler,
    Telemetry
  }

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
  @spec send(Connection.t(), map(), list()) ::
          {:ok, Response.t()}
          | {:error,
               ExNylas.APIError.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()
               | ExNylas.FileError.t()}
  def send(%Connection{} = conn, message, attachments \\ []) do
    case Multipart.build_multipart(message, attachments) do
      {:ok, {body, content_type, len}} ->
        Req.new(
          url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/send",
          auth: Auth.auth_bearer(conn),
          headers: API.base_headers(["content-type": content_type, "content-length": to_string(len)]),
          body: body
        )
        |> Telemetry.maybe_attach_telemetry(conn)
        |> Req.post(conn.options)
        |> ResponseHandler.handle_response(Message)

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Send a message.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  ## Examples

      iex> sent_message = ExNylas.Messages.send!(conn, message, ["path_to_attachment"])
  """
  @spec send!(Connection.t(), map(), list()) :: Response.t()
  def send!(%Connection{} = conn, message, attachments \\ []) do
    case send(conn, message, attachments) do
      {:ok, body} -> body
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Send a message using raw MIME format.

  ## Examples

      iex> {:ok, sent_message} = ExNylas.Messages.send_raw(conn, mime)
  """
  @spec send_raw(Connection.t(), String.t()) ::
          {:ok, Response.t()}
          | {:error,
               ExNylas.APIError.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()}
  def send_raw(%Connection{} = conn, mime) do
    {body, content_type, len} = Multipart.build_raw_multipart(mime)

    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/send?type=mime",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(["content-type": content_type, "content-length": to_string(len)]),
      body: body
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(Message)
  end

  @doc """
  Send a message using raw MIME format.

  ## Examples

      iex> sent_message = ExNylas.Messages.send_raw!(conn, mime)
  """
  @spec send_raw!(Connection.t(), String.t()) :: Response.t()
  def send_raw!(%Connection{} = conn, mime) do
    case send_raw(conn, mime) do
      {:ok, body} -> body
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Clean a message.

  ## Examples

      iex> {:ok, message} = ExNylas.Messages.clean(conn, payload)
  """
  @spec clean(Connection.t(), map()) ::
          {:ok, Response.t()}
          | {:error,
               ExNylas.APIError.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()}
  def clean(%Connection{} = conn, payload) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/messages/clean",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(),
      json: payload
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.put(conn.options)
    |> ResponseHandler.handle_response(Message)
  end

  @doc """
  Clean a message.

  ## Examples

      iex> message = ExNylas.Messages.clean!(conn, payload)
  """
  @spec clean!(Connection.t(), map()) :: Response.t()
  def clean!(%Connection{} = conn, payload) do
    case clean(conn, payload) do
      {:ok, body} -> body
      {:error, exception} -> raise exception
    end
  end
end
