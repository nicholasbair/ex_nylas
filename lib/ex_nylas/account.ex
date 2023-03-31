defmodule ExNylas.Account do
  @moduledoc """
  A struct representing an account & interface for Nylas account.
  """

  defstruct [:id, :account_id, :object,  :name, :email_address, :provider, :organization_unit, :sync_state, :linked_at]

  @type t :: %__MODULE__{
    id: String.t(),
    account_id: String.t(),
    object: String.t(),
    name: String.t(),
    email_address: String.t(),
    provider: String.t(),
    organization_unit: String.t(),
    sync_state: String.t(),
    linked_at: non_neg_integer(),
  }

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  def as_struct, do: %ExNylas.Account{}

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
    |> API.handle_response(as_struct())
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
