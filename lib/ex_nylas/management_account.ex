defmodule ExNylas.ManagementAccount do
  @moduledoc """
  A struct representing a management account.
  """

  defstruct [
    :id,
    :billing_state,
    :email_address,
    :namespace_id,
    :provider,
    :sync_state,
    :trial,
    :authentication_type,
  ]

  @typedoc "A management account"
  @type t :: %__MODULE__{
    id: String.t(),
    billing_state: String.t(),
    email_address: String.t(),
    namespace_id: String.t(),
    provider: String.t(),
    sync_state: String.t(),
    trial: boolean(),
    authentication_type: String.t(),
  }

  def as_struct() do
    %ExNylas.ManagementAccount{}
  end

  def as_list, do: [as_struct()]

  defmodule Downgrade do
    defstruct [
      :success
    ]

    @typedoc "A management account downgrade"
    @type t :: %__MODULE__{
      success: boolean()
    }
  end

  defmodule Upgrade do
    defstruct [
      :success
    ]

    @typedoc "A management account upgrade"
    @type t :: %__MODULE__{
      success: boolean()
    }
  end

  defmodule IPAddresses do
    defstruct [
      :ip_addresses,
      :updated_at,
    ]

    @typedoc "A management account IP addresses"
    @type t :: %__MODULE__{
      ip_addresses: list(),
      updated_at: non_neg_integer(),
    }
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
  Delete an account.

  Example
      {:ok, result} = conn |> ExNylas.ManagementAccounts.delete(`id`)
  """
  def delete(%Conn{} = conn, account_id) do
    API.delete(
      "#{conn.api_server}/a/#{conn.client_id}/accounts/#{account_id}",
      API.header_basic(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response()
  end

  @doc """
  Delete an account.

  Example
      result = conn |> ExNylas.ManagementAccounts.delete!(`id`)
  """
  def delete!(%Conn{} = conn, account_id) do
    case delete(conn, account_id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

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
