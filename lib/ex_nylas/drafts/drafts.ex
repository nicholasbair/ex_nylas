defmodule ExNylas.Drafts do
  @moduledoc """
  Interface for Nylas Drafts.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/drafts)
  """

  alias ExNylas.API
  alias ExNylas.Response
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Draft

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
  @spec create(Conn.t(), map(), list()) :: {:ok, Response.t()} | {:error, Response.t()}
  def create(%Conn{} = conn, draft, attachments \\ []) do
    {body, content_type, len} = API.build_multipart(draft, attachments)

    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": content_type, "content-length": to_string(len)]),
      body: body
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(Draft)
  end

  @doc """
  Create a draft.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  ## Examples

      iex> draft = ExNylas.Drafts.create!(conn, draft, ["path_to_attachment"])
  """
  @spec create!(Conn.t(), map(), list()) :: Response.t()
  def create!(%Conn{} = conn, draft, attachments \\ []) do
    case create(conn, draft, attachments) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Update a draft.

  To add attachments greater than 3MB, use `update/4` or `update!/4`.

  ## Examples

      iex> {:ok, draft} = ExNylas.Drafts.update(conn, id, changeset)
  """
  @spec update(Conn.t(), String.t(), map()) :: {:ok, Response.t()} | {:error, Response.t()}
  def update(%Conn{} = conn, id, changeset) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{id}",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": "application/json"]),
      json: changeset
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.patch(conn.options)
    |> API.handle_response(Draft)
  end

  @doc """
  Update a draft.

  To add attachments greater than 3MB, use `update/4` or `update!/4`.

  ## Examples

      iex> draft = ExNylas.Drafts.update!(conn, id, changeset)
  """
  @spec update!(Conn.t(), String.t(), map()) :: Response.t()
  def update!(%Conn{} = conn, id, changeset) do
    case update(conn, id, changeset) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Update a draft.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  To remove all attachments from a draft, use `update/3` or `update!/3`.

  ## Examples

      iex> {:ok, draft} = ExNylas.Drafts.update(conn, id, changeset, ["path_to_attachment"])
  """
  @spec update(Conn.t(), String.t(), map(), list()) :: {:ok, Response.t()} | {:error, Response.t()}
  def update(%Conn{} = conn, id, changeset, attachments) do
    {body, content_type, len} = API.build_multipart(changeset, attachments)

    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{id}",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(["content-type": content_type, "content-length": to_string(len)]),
      body: body
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.patch(conn.options)
    |> API.handle_response(Draft)
  end

  @doc """
  Update a draft.  Attachments must be either a list of file paths or a list of tuples with the content-id and file path.  The latter of which is needed in order to attach inline images.

  To remove all attachments from a draft, use `update/3` or `update!/3`.

  ## Examples

      iex> draft = ExNylas.Drafts.update!(conn, id, changeset, ["path_to_attachment"])
  """
  @spec update!(Conn.t(), String.t(), map(), list()) :: Response.t()
  def update!(%Conn{} = conn, id, changeset, attachments) do
    case update(conn, id, changeset, attachments) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send a draft.

  ## Examples

      iex> {:ok, sent_draft} = ExNylas.Drafts.send(conn, draft_id)
  """
  @spec send(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def send(%Conn{} = conn, draft_id) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{draft_id}",
      auth: API.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(Draft)
  end

  @doc """
  Send a draft.

  ## Examples

      iex> sent_draft = ExNylas.Drafts.send!(conn, draft_id)
  """
  @spec send!(Conn.t(), String.t()) :: Response.t()
  def send!(%Conn{} = conn, draft_id) do
    case send(conn, draft_id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
