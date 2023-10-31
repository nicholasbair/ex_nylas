defmodule ExNylas.Drafts do
  @moduledoc """
  Interface for Nylas Drafts.
  """

  alias ExNylas.API
  alias ExNylas.Common
  alias ExNylas.Connection, as: Conn

  # Avoid conflict between Kernel.send/2 and __MODULE__.send/2
  import Kernel, except: [send: 2]

  use ExNylas,
    object: "drafts",
    struct: ExNylas.Model.Draft,
    readable_name: "draft",
    include: [:list, :first, :find, :delete, :build, :all]

  @doc """
  Create a draft.

  Example
      {:ok, draft} = conn |> ExNylas.Drafts.create(`draft`, `["path_to_attachment"]`)
  """
  def create(%Conn{} = conn, draft, attachments \\ []) do
    API.post(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts",
      Common.build_multipart_body(draft, attachments),
      API.header_bearer(conn) ++ ["content-type": "multipart/form-data"],
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.Draft.as_struct())
  end

  @doc """
  Create a draft.

  Example
      draft = conn |> ExNylas.Drafts.create!(`draft`, `["path_to_attachment"]`)
  """
  def create!(%Conn{} = conn, draft, attachments \\ []) do
    case create(conn, draft, attachments) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Update a draft.

  To add attachments greater than 3MB, use update/4 or update!/4.

  Example
      {:ok, draft} = conn |> ExNylas.Drafts.update(`id`, `changeset`)
  """
  def update(%Conn{} = conn, id, changeset) do
    API.patch(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{id}",
      changeset,
      API.header_bearer(conn) ++ ["content-type": "application/json"],
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.Draft.as_struct())
  end

  @doc """
  Update a draft.

  To add attachments greater than 3MB, use update/4 or update!/4.

  Example
      draft = conn |> ExNylas.Drafts.update!(`id`, `changeset`)
  """
  def update!(%Conn{} = conn, id, changeset) do
    case update(conn, id, changeset) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Update a draft.

  To remove all attachments from a draft, use update/3 or update!/3.

  Example
      {:ok, draft} = conn |> ExNylas.Drafts.update(`id`, `changeset`, `["path_to_attachment"]`)
  """
  def update(%Conn{} = conn, id, changeset, attachments) do
    API.patch(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{id}",
      Common.build_multipart_body(changeset, attachments),
      API.header_bearer(conn) ++ ["content-type": "multipart/form-data"],
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.Draft.as_struct())
  end

  @doc """
  Update a draft.

  To remove all attachments from a draft, use update/3 or update!/3.

  Example
      draft = conn |> ExNylas.Drafts.update!(`id`, `changeset`, `["path_to_attachment"]`)
  """
  def update!(%Conn{} = conn, id, changeset, attachments) do
    case update(conn, id, changeset, attachments) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send a draft.

  Example
      {:ok, sent_draft} = conn |> ExNylas.Drafts.send(`draft_id`)
  """
  def send(%Conn{} = conn, draft_id) do
    API.post(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{draft_id}",
      %{},
      API.header_bearer(conn) ++ ["content-type": "application/json"],
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.Draft.as_struct())
  end

  @doc """
  Send a draft.

  Example
      sent_draft = conn |> ExNylas.Drafts.send!(`draft_id`)
  """
  def send!(%Conn{} = conn, draft_id) do
    case send(conn, draft_id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
