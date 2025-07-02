defmodule ExNylas.Attachments do
  @moduledoc """
  Interface for Nylas attachments.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/attachments)
  """

  alias ExNylas.{API, Auth, ResponseHandler, Telemetry}
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Response

  use ExNylas,
    object: "attachments",
    struct: ExNylas.Attachment,
    readable_name: "attachment",
    include: [:find]

  @doc """
  Download an attachment.  Message ID is required.

  ## Examples

      iex> {:ok, result} = ExNylas.Attachments.download(conn, id, message_id: message_id)
  """
  @spec download(Conn.t(), String.t(), Keyword.t() | list()) :: {:ok, String.t()} | {:error, Response.t()}
  def download(%Conn{} = conn, id, params \\ []) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/attachments/#{id}/download",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers([accept: "application/octet-stream"]),
      params: params,
      decode_body: false
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> ResponseHandler.handle_response()
  end

  @doc """
  Download an attachment.  Message ID is required.

  ## Examples

      iex> result = ExNylas.Attachments.download!(conn, id, message_id: message_id)
  """
  @spec download!(Conn.t(), String.t(), Keyword.t() | list()) :: String.t()
  def download!(%Conn{} = conn, id, params \\ []) do
    case download(conn, id, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
