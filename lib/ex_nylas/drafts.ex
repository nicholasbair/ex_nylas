defmodule ExNylas.Drafts do
  @moduledoc """
  Interface for Nylas Drafts.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  # Avoid conflict between Kernel.send/2 and __MODULE__.send/2
  import Kernel, except: [send: 2]

  use ExNylas,
    object: "drafts",
    struct: ExNylas.Model.Draft,
    include: [:list, :first, :find, :delete, :build, :create, :update, :all]

  @doc """
  Send a draft.

  Example
      {:ok, sent_draft} = conn |> ExNylas.Drafts.send(`draft_id`)
  """
  def send(%Conn{} = conn, draft_id) do
    API.post(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/drafts/#{draft_id}",
      %{},
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Model.Message)
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
