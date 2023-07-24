defmodule ExNylas.Authentication do
  alias ExNylas.Authentication.TokenInfo
  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  defmodule RevokeAll do
    defstruct [:success]
    @type t :: %__MODULE__{success: boolean()}

    def as_struct(), do: %ExNylas.Authentication.RevokeAll{}
  end

  defmodule TokenInfo do
    defstruct [:created_at, :scopes, :state, :updated_at]

    @type t :: %__MODULE__{
      created_at: non_neg_integer(),
      scopes: String.t(),
      state: String.t(),
      updated_at: non_neg_integer()
    }

    def as_struct(), do: %ExNylas.Authentication.TokenInfo{}
  end

  @doc """
  Revoke an access token

  Example
      {:ok, res} = ExNylas.Authentication.revoke_token(conn)
  """
  def revoke_token(%Conn{} = conn) do
    API.post(
      "#{conn.api_server}/oauth/revoke",
      %{},
      API.header_basic(conn) ++
        ["content-type": "application/json"]
    )
    |> API.handle_response()
  end

  @doc """
  Revoke an access token

  Example
      res = ExNylas.Authentication.revoke_token!(conn)
  """
  def revoke_token!(%Conn{} = conn) do
    case revoke_token(conn) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Revoke all tokens for a given account.

  Example
      {:ok, result} = conn |> ExNylas.Authentication.revoke_all(`id`)
  """
  def revoke_all(%Conn{} = conn, id, token_to_keep \\ nil) do
    body =
      case token_to_keep do
        nil -> %{}
        _ -> %{keep_access_token: token_to_keep}
      end

    API.post(
      "#{conn.api_server}/a/#{conn.client_id}/accounts/#{id}/revoke-all",
      body,
      API.header_basic(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Authentication.RevokeAll.as_struct())
  end

  @doc """
  Revoke all tokens for a given account.

  Example
      result = conn |> ExNylas.Authentication.revoke_all!(`id`)
  """
  def revoke_all!(%Conn{} = conn, id) do
    case revoke_all(conn, id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Get token information for a given account.

  Example
      {:ok, result} = conn |> ExNylas.Authentication.token_info(`id`)
  """
  def token_info(%Conn{} = conn, id) do
    API.post(
      "#{conn.api_server}/a/#{conn.client_id}/accounts/#{id}/token-info",
      %{access_token: conn.access_token},
      API.header_basic(conn)
    )
    |> API.handle_response(ExNylas.Authentication.TokenInfo.as_struct())
  end

  @doc """
  Get token information for a given account.

  Example
      result = conn |> ExNylas.Authentication.token_info!(`id`)
  """
  def token_info!(%Conn{} = conn, id) do
    case token_info(conn, id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  defmodule Native do
  @moduledoc """
  Nylas native authentication
  """

    defstruct [
      :id,
      :object,
      :account_id,
      :name,
      :provider,
      :organization_unit,
      :sync_state,
      :linked_at,
      :email_address,
      :access_token,
      :billing_state,
    ]

    @typedoc "Native authentication response"
    @type t :: %__MODULE__{
      id: String.t(),
      object: String.t(),
      account_id: String.t(),
      name: String.t(),
      provider: String.t(),
      organization_unit: String.t(),
      sync_state: String.t(),
      linked_at: non_neg_integer(),
      email_address: String.t(),
      access_token: String.t(),
      billing_state: String.t()
    }

    def as_struct(), do: %ExNylas.Authentication.Native{}

    defmodule Settings do
      defstruct [
        :google_client_id,
        :google_client_secret,
        :google_refresh_token,
        :microsoft_client_id,
        :microsoft_client_secret,
        :microsoft_refresh_token,
        :redirect_uri,
        :imap_host,
        :imap_port,
        :imap_username,
        :imap_password,
        :smtp_host,
        :smtp_port,
        :smtp_username,
        :smtp_password,
        :ssl_required,
        :password,
        :username,
        :exchange_server_host,
        :service_account,
        :service_account_json,
        :type,
        :project_id,
        :private_key_id,
        :private_key,
        :client_email,
        :client_id,
        :auth_uri,
        :token_uri,
        :auth_provider_x509_cert_url,
        :client_x509_cert_url,
      ]

      @type t :: %__MODULE__{
        google_client_id: String.t(),
        google_client_secret: String.t(),
        google_refresh_token: String.t(),
        microsoft_client_id: String.t(),
        microsoft_client_secret: String.t(),
        microsoft_refresh_token: String.t(),
        redirect_uri: String.t(),
        imap_host: String.t(),
        imap_port: non_neg_integer,
        imap_username: String.t(),
        imap_password: String.t(),
        smtp_host: String.t(),
        smtp_port: non_neg_integer,
        smtp_username: String.t(),
        smtp_password: String.t(),
        ssl_required: boolean(),
        password: String.t(),
        username: String.t(),
        exchange_server_host: String.t(),
        service_account: boolean(),
        service_account_json: String.t(),
        type: String.t(),
        project_id: String.t(),
        private_key_id: String.t(),
        private_key: String.t(),
        client_email: String.t(),
        client_id: String.t(),
        auth_uri: String.t(),
        token_uri: String.t(),
        auth_provider_x509_cert_url: String.t(),
        client_x509_cert_url: String.t(),
      }
    end

    @doc """
    Connect an account using native auth with a single function call, uses ExNylas.Authentication.Native.authorize/6 and ExNylas.Authentication.Native.exchange_code_for_token/3 in the background.

    Example
        {:ok, res} = ExNylas.Authentication.Native.connect(conn, "Test McTest", "nick@exmaple.com", %{username: "nick@example.com, password: 1234}, "email.read_only")
    """
    def connect(%Conn{} = conn, name, email_address, provider, settings, scopes) do
      case authorize(conn, name, email_address, provider, settings, scopes) do
        {:ok, res} -> exchange_code_for_token(conn, res["code"])
        err -> err
      end
    end

    @doc """
    Connect an account using native auth with a single function call, uses ExNylas.Authentication.Native.authorize!/6 and ExNylas.Authentication.Native.exchange_code_for_token!/3 in the background.

    Example
        res = ExNylas.Authentication.Native.connect!(conn, "Test McTest", "nick@exmaple.com", %{username: "nick@example.com, password: 1234}, "email.read_only")
    """
    def connect!(%Conn{} = conn, name, email_address, provider, settings, scopes) do
      case connect(conn, name, email_address, provider, settings, scopes) do
        {:ok, res} -> res
        {:error, reason} -> raise ExNylasError, reason
      end
    end

    @doc """
    Send an authorization request to Nylas.

    Example
        {:ok, res} = ExNylas.Authentication.Native.authorize(conn, "Test McTest", "nick@exmaple.com", %{username: "nick@example.com, password: 1234}, "email.read_only")
    """
    def authorize(%Conn{} = conn, name, email_address, provider, settings, scopes) when is_list(scopes) do
      authorize(conn, name, email_address, provider, settings, Enum.join(scopes, ","))
    end

    def authorize(%Conn{} = conn, name, email_address, provider, settings, scopes) when is_bitstring(scopes) do
      API.post(
        "#{conn.api_server}/connect/authorize",
        %{
          client_id: conn.client_id,
          name: name,
          email_address: email_address,
          provider: provider,
          settings: settings,
          scopes: scopes
        },
        ["content-type": "application/json"]
      )
      |> API.handle_response()
    end

    @doc """
    Send an authorization request to Nylas.

    Example
        res = ExNylas.Authentication.Native.authorize!(conn, "Test McTest", "nick@exmaple.com", %{username: "nick@example.com, password: 1234}, "email.read_only")
    """
    def authorize!(%Conn{} = conn, name, email_address, provider, settings, scopes) when is_list(scopes) do
      authorize!(conn, name, email_address, provider, settings, Enum.join(scopes, ","))
    end

    def authorize!(%Conn{} = conn, name, email_address, provider, settings, scopes) when is_bitstring(scopes) do
      case authorize(conn, name, email_address, provider, settings, scopes) do
        {:ok, res} -> res
        {:error, reason} -> raise ExNylasError, reason
      end
    end

    @doc """
    Exchange an authorization code for a Nylas access token

    Example
        {:ok, access_token} = ExNylas.Authentication.Native.exchange_code_for_token(conn, code)
    """
    def exchange_code_for_token(%Conn{} = conn, code) do
      API.post(
        "#{conn.api_server}/connect/token",
        %{
          client_id: conn.client_id,
          client_secret: conn.client_secret,
          grant_type: "authorization_code",
          code: code
        },
        ["content-type": "application/json"]
      )
      |> API.handle_response(as_struct())
    end

    @doc """
    Exchange an authorization code for a Nylas access token

    Example
        access_token = ExNylas.Authentication.Native.exchange_code_for_token!(conn, code)
    """
    def exchange_code_for_token!(%Conn{} = conn, code) do
      case exchange_code_for_token(conn, code) do
        {:ok, res} -> res
        {:error, reason} -> raise ExNylasError, reason
      end
    end
  end
end
