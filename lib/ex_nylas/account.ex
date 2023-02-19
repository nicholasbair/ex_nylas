defmodule ExNylas.Account do
  @moduledoc """
  A struct representing an account & interface for Nylas account.
  """
  use TypedStruct

  typedstruct do
    @typedoc "An account"
    field(:id, String.t())
    field(:account_id, String.t())
    field(:object, String.t())
    field(:name, String.t())
    field(:email_address, String.t())
    field(:provider, String.t())
    field(:organization_unit, String.t())
    field(:sync_state, String.t())
    field(:linked_at, integer())
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Get the account associated with the `access_token`.

  Example
      {:ok, result} = conn |> ExNylas.Account.get()
  """
  def get(%Conn{} = conn) do
    API.get(
      "#{conn.api_server}/account",
      API.header_bearer(conn)
    )
    |> API.handle_response(__MODULE__)
  end

  @doc """
  Get the account associated with the `access_token`.

  Example
      result = conn |> ExNylas.Account.get!()
  """
  def get!(%Conn{} = conn) do
    case get(conn) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
