defmodule ExNylas.Grants do
  @moduledoc """
  Interface for Nylas grants.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Delete a grant.

  Example
      {:ok, _} = conn |> ExNylas.Grants.delete(`id`)
  """
  def delete(%Conn{} = conn, id) do
    API.delete(
      conn.api_server <> "/grants/" <> id,
      API.header_api_key(conn)
    )
    |> API.handle_response()
  end

  @doc """
  Delete a grant.

  Example
      conn |> ExNylas.Grants.delete!(`id`)
  """
  def delete!(%Conn{} = conn, id) do
    case delete(conn, id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
