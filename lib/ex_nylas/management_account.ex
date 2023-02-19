defmodule ExNylas.ManagementAccount do
  @moduledoc """
  A struct representing a management account.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A management account"
    field(:id, String.t())
    field(:billing_state, String.t())
    field(:email_address, String.t())
    field(:namespace_id, String.t())
    field(:provider, String.t())
    field(:sync_state, String.t())
    field(:trial, boolean())
    field(:authentication_type, String.t())
  end

  typedstruct module: Downgrade do
    @typedoc "A management account downgrade"
    field(:success, boolean())
  end

  typedstruct module: Upgrade do
    @typedoc "A management account upgrade"
    field(:success, boolean())
  end

  typedstruct module: IPAddresses do
    @typedoc "A management account IP addresses"
    field(:ip_addresses, list())
    field(:updated_at, non_neg_integer())
  end
end

defmodule ExNylas.ManagementAccounts do
  @moduledoc """
  Interface for Nylas management accounts
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  use ExNylas,
    object: "accounts",
    struct: ExNylas.ManagementAccount,
    include: [:list, :find, :all],
    header_type: :header_basic,
    use_client_url: true

  @doc """
  Downgrade the management account.

  Example
      {:ok, result} = conn |> ExNylas.ManagementAccounts.downgrade(`id`)
  """
  def downgrade(%Conn{} = conn, account_id) do
    API.post(
      "#{conn.api_server}/a/#{conn.client_id}/accounts/#{account_id}/downgrade",
      %{},
      API.header_basic(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.ManagementAccount.Downgrade)
  end

  @doc """
  Downgrade the management account.

  Example
      result = conn |> ExNylas.ManagementAccounts.downgrade!(`id`)
  """
  def downgrade!(%Conn{} = conn, account_id) do
    case downgrade(conn, account_id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Upgrade the management account.

  Example
      {:ok, result} = conn |> ExNylas.ManagementAccounts.upgrade(`id`)
  """
  def upgrade(%Conn{} = conn, account_id) do
    API.post(
      "#{conn.api_server}/a/#{conn.client_id}/accounts/#{account_id}/upgrade",
      %{},
      API.header_basic(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.ManagementAccount.Upgrade)
  end

  @doc """
  Upgrade the management account.

  Example
      result = conn |> ExNylas.ManagementAccounts.upgrade!(`id`)
  """
  def upgrade!(%Conn{} = conn, account_id) do
    case upgrade(conn, account_id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Get IP Addresses.

  Example
      {:ok, result} = conn |> ExNylas.ManagementAccounts.ip_addresses()
  """
  def ip_addresses(%Conn{} = conn) do
    API.get(
      "#{conn.api_server}/a/#{conn.client_id}/ip_addresses",
      API.header_basic(conn)
    )
    |> API.handle_response(ExNylas.ManagementAccount.IPAddresses)
  end

  @doc """
  Get IP Addresses.

  Example
      result = conn |> ExNylas.ManagementAccounts.ip_addresses!()
  """
  def ip_addresses!(%Conn{} = conn) do
    case ip_addresses(conn) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
