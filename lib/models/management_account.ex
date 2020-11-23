defmodule ExNylas.ManagementAccount do
  @moduledoc """
  A struct representing a management account.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A management account"
    field :id, String.t()
    field :billing_state, String.t()
    field :email_address, String.t()
    field :namespace_id, String.t()
    field :provider, String.t()
    field :sync_state, String.t()
    field :trial, boolean()
  end

end

defmodule ExNylas.ManagementAccount.Downgrade do
  @moduledoc """
  A struct representing a management account downgrade.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A management account downgrade"
    field :success, boolean()
  end

end

defmodule ExNylas.ManagementAccount.Upgrade do
  @moduledoc """
  A struct representing a management account upgrade.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A management account upgrade"
    field :success, boolean()
  end

end

defmodule ExNylas.ManagementAccount.RevokeAll do
  @moduledoc """
  A struct representing a management account revoke all.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A management account revoke all"
    field :success, boolean()
  end

end

defmodule ExNylas.ManagementAccount.IPAddresses do
  @moduledoc """
  A struct representing a management account IP addresses.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A management account IP addresses"
    field :ip_addresses, list()
    field :updated_at,   non_neg_integer()
  end

end

defmodule ExNylas.ManagementAccount.TokenInfo do
  @moduledoc """
  A struct representing a management account token info.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A management account token info"
    field :created_at, non_neg_integer()
    field :scopes,     String.t()
    field :state,      String.t()
    field :updated_at, non_neg_integer()
  end

end

defmodule ExNylas.ManagementAccounts do
  @moduledoc """
  Interface for Nylas management accounts
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  use ExNylas,
    object: "accounts",
    struct: ExNylas.ManagementAccount,
    only: [:list, :find],
    header_type: :header_basic,
    use_client_url: true

  @doc """
  Downgrade the management account.

  Example
      {:ok, result} = conn |> ExNylas.ManagementAccounts.downgrade()
  """
  def downgrade(%Conn{} = conn) do
    res =
      API.post(
        "#{conn.api_server}/a/#{conn.client_id}/downgrade",
        API.header_basic(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.ManagementAccount.Downgrade)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Downgrade the management account.

  Example
      result = conn |> ExNylas.ManagementAccounts.downgrade!()
  """
  def downgrade!(%Conn{} = conn) do
    case downgrade(conn) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Upgrade the management account.

  Example
      {:ok, result} = conn |> ExNylas.ManagementAccounts.upgrade()
  """
  def upgrade(%Conn{} = conn) do
    res =
      API.post(
        "#{conn.api_server}/a/#{conn.client_id}/upgrade",
        API.header_basic(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.ManagementAccount.Upgrade)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Upgrade the management account.

  Example
      result = conn |> ExNylas.ManagementAccounts.upgrade!()
  """
  def upgrade!(%Conn{} = conn) do
    case upgrade(conn) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Revoke all tokens for a given account.

  Example
      {:ok, result} = conn |> ExNylas.ManagementAccounts.revoke_all(`id`)
  """
  def revoke_all(%Conn{} = conn, id) do
    res =
      API.post(
        "#{conn.api_server}/a/#{conn.client_id}/accounts/#{id}/revoke-all",
        API.header_basic(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.ManagementAccount.RevokeAll)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Revoke all tokens for a given account.

  Example
      result = conn |> ExNylas.ManagementAccounts.revoke_all!(`id`)
  """
  def revoke_all!(%Conn{} = conn, id) do
    case revoke_all(conn, id) do
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
    res =
      API.get(
        "#{conn.api_server}/a/#{conn.client_id}/ip_addresses",
        API.header_basic(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.ManagementAccount.IPAddresses)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
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

  @doc """
  Get token information for a given account.

  Example
      {:ok, result} = conn |> ExNylas.ManagementAccounts.token_info(`id`)
  """
  def token_info(%Conn{} = conn, id) do
    res =
      API.post(
        "#{conn.api_server}/a/#{conn.client_id}/accounts/#{id}/token-info",
        API.header_basic(conn),
        %{access_token: conn.access_token}
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.ManagementAccount.IPAddresses)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Get token information for a given account.

  Example
      result = conn |> ExNylas.ManagementAccounts.token_info!(`id`)
  """
  def token_info!(%Conn{} = conn, id) do
    case token_info(conn, id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

end
