defmodule ExNylas.Attachments do
  @moduledoc """
  Interface for Nylas attachments.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  use ExNylas,
    object: "attachments",
    struct: ExNylas.Attachment,
    readable_name: "attachment",
    include: [:find]

  @doc """
  Download an attachment.

  ## Examples

      iex> {:ok, result} = ExNylas.Attachments.download(conn, id, message_id)
  """
  def download(%Conn{} = conn, id, message_id) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/attachments/#{id}/download",
      auth: API.auth_bearer(conn),
      headers: API.base_headers([accept: "application/octet-stream"]),
      params: %{message_id: message_id},
      decode_body: false
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> API.handle_response()
  end

  @doc """
  Download an attachment.

  ## Examples

      iex> result = ExNylas.Attachments.download!(conn, id, message_id)
  """
  def download!(%Conn{} = conn, id, message_id) do
    case download(conn, id, message_id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
