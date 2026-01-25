defmodule ExNylas.Drafts do
  @moduledoc """
  Interface for Nylas Drafts.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/drafts)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    Draft,
    Multipart,
    Response,
    ResponseHandler,
    Telemetry
  }

  # Avoid conflict between Kernel.send/2 and __MODULE__.send/2
  import Kernel, except: [send: 2]

  use ExNylas,
    object: "drafts",
    struct: Draft,
    readable_name: "draft",
    include: [:list, :first, :find, :delete, :build, :all]

  @doc """
  Create a draft.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  ## Examples

      iex> {:ok, draft} = ExNylas.Drafts.create(conn, draft, ["path_to_attachment"])
  """
  @spec create(Connection.t(), map(), list()) :: {:ok, Response.t()} | {:error, ExNylas.APIError.t() | ExNylas.TransportError.t() | ExNylas.FileError.t()}
  def create(%Connection{} = conn, draft, attachments \\ []) do
    case Multipart.build_multipart(draft, attachments) do
      {:ok, {body, content_type, len}} ->
        Req.new(
          url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts",
          auth: Auth.auth_bearer(conn),
          headers: API.base_headers(["content-type": content_type, "content-length": to_string(len)]),
          body: body
        )
        |> Telemetry.maybe_attach_telemetry(conn)
        |> Req.post(conn.options)
        |> ResponseHandler.handle_response(Draft)

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Create a draft.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  ## Examples

      iex> draft = ExNylas.Drafts.create!(conn, draft, ["path_to_attachment"])
  """
  @spec create!(Connection.t(), map(), list()) :: Response.t()
  def create!(%Connection{} = conn, draft, attachments \\ []) do
    case create(conn, draft, attachments) do
      {:ok, body} -> body
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Update a draft.

  To add attachments greater than 3MB, use `update/4` or `update!/4`.

  ## Examples

      iex> {:ok, draft} = ExNylas.Drafts.update(conn, id, changeset)
  """
  @spec update(Connection.t(), String.t(), map()) :: {:ok, Response.t()} | {:error, ExNylas.APIError.t() | ExNylas.TransportError.t()}
  def update(%Connection{} = conn, id, changeset) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{id}",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: changeset
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.patch(conn.options)
    |> ResponseHandler.handle_response(Draft)
  end

  @doc """
  Update a draft.

  To add attachments greater than 3MB, use `update/4` or `update!/4`.

  ## Examples

      iex> draft = ExNylas.Drafts.update!(conn, id, changeset)
  """
  @spec update!(Connection.t(), String.t(), map()) :: Response.t()
  def update!(%Connection{} = conn, id, changeset) do
    case update(conn, id, changeset) do
      {:ok, body} -> body
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Update a draft.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  To remove all attachments from a draft, use `update/3` or `update!/3`.

  ## Examples

      iex> {:ok, draft} = ExNylas.Drafts.update(conn, id, changeset, ["path_to_attachment"])
  """
  @spec update(Connection.t(), String.t(), map(), list()) :: {:ok, Response.t()} | {:error, ExNylas.APIError.t() | ExNylas.TransportError.t() | ExNylas.FileError.t()}
  def update(%Connection{} = conn, id, changeset, attachments) do
    case Multipart.build_multipart(changeset, attachments) do
      {:ok, {body, content_type, len}} ->
        Req.new(
          url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{id}",
          auth: Auth.auth_bearer(conn),
          headers: API.base_headers(["content-type": content_type, "content-length": to_string(len)]),
          body: body
        )
        |> Telemetry.maybe_attach_telemetry(conn)
        |> Req.patch(conn.options)
        |> ResponseHandler.handle_response(Draft)

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Update a draft.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  To remove all attachments from a draft, use `update/3` or `update!/3`.

  ## Examples

      iex> draft = ExNylas.Drafts.update!(conn, id, changeset, ["path_to_attachment"])
  """
  @spec update!(Connection.t(), String.t(), map(), list()) :: Response.t()
  def update!(%Connection{} = conn, id, changeset, attachments) do
    case update(conn, id, changeset, attachments) do
      {:ok, body} -> body
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Send a draft.

  ## Examples

      iex> {:ok, sent_draft} = ExNylas.Drafts.send(conn, draft_id)
  """
  @spec send(Connection.t(), String.t()) :: {:ok, Response.t()} | {:error, ExNylas.APIError.t() | ExNylas.TransportError.t()}
  def send(%Connection{} = conn, draft_id) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{draft_id}",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(Draft)
  end

  @doc """
  Send a draft.

  ## Examples

      iex> sent_draft = ExNylas.Drafts.send!(conn, draft_id)
  """
  @spec send!(Connection.t(), String.t()) :: Response.t()
  def send!(%Connection{} = conn, draft_id) do
    case send(conn, draft_id) do
      {:ok, body} -> body
      {:error, exception} -> raise exception
    end
  end
end
