defmodule ExNylas.Grant do
  @moduledoc """
  A struct represting a Nylas grant.
  """

  defstruct [
    :id,
    :provider,
    :grant_status,
    :email,
    :scope,
    :user_agent,
    :ip,
    :state,
    :created_at,
    :updated_at,
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    provider: String.t(),
    grant_status: String.t(),
    email: String.t(),
    scope: [String.t()],
    user_agent: String.t(),
    ip: String.t(),
    state: String.t(),
    created_at: String.t(),
    updated_at: String.t(),
  }

  def as_struct(), do: %ExNylas.Grant{}

  def as_list(), do: [as_struct()]
end

defmodule ExNylas.Grants do
  @moduledoc """
  Interface for Nylas grants.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Get a grant.

  Example
      {:ok, _} = conn |> ExNylas.Grants.get()
  """
  def find(%Conn{} = conn) do
    API.get(
      conn.api_server <> "/v3/grants/" <> conn.grant_id,
      API.header_api_key(conn)
    )
    |> API.handle_response(ExNylas.Grant.as_struct())
  end

  @doc """
  Get a grant.

  Example
      conn |> ExNylas.Grants.get!()
  """
  def find!(%Conn{} = conn) do
    case find(conn) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

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
