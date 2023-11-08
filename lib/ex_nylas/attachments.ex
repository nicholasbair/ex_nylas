defmodule ExNylas.Attachments do
  @moduledoc """
  Interface for Nylas attachments.
  """

  use ExNylas,
    object: "attachments",
    struct: ExNylas.Model.Attachment,
    readable_name: "attachment",
    include: [:find]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Download an attachment.

  Example
      {:ok, result} = conn |> ExNylas.Attachments.download(`id`, %{message_id: `message_id`})
  """
  def download(%Conn{} = conn, id, params \\ %{}) do
    API.get(
      "#{conn.api_server}/v3/grants/#{conn.grant_id}/attachments/#{id}/download",
      API.header_bearer(conn) |> Keyword.replace(:accept, "application/octet-stream"),
      [
        timeout: conn.timeout,
        recv_timeout: conn.recv_timeout,
        params: params
      ]
    )
    |> API.handle_response()
  end

  @doc """
  Download an attachment.

  Example
      result = conn |> ExNylas.Attachments.download!(`id`, %{message_id: `message_id`})
  """
  def download!(%Conn{} = conn, id, params \\ %{}) do
    case download(conn, id, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
