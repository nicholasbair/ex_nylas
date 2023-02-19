defmodule ExNylas.Authentication do
  alias ExNylas.Authentication.TokenInfo
  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  use TypedStruct

  typedstruct module: RevokeAll do
    @typedoc "Revoke all response"
    field(:success, boolean())
  end

  typedstruct module: TokenInfo do
    @typedoc "Token info response"
    field(:created_at, non_neg_integer())
    field(:scopes, String.t())
    field(:state, String.t())
    field(:updated_at, non_neg_integer())
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
      API.header_basic(conn.access_token, conn.api_version) ++
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
      API.header_basic(conn)
    )
    |> API.handle_response(RevokeAll)
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
    |> API.handle_response(TokenInfo)
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

  defmodule Hosted do
    @moduledoc """
    Nylas hosted authentication
    """

    use TypedStruct

    typedstruct do
      @typedoc "Hosted authentication response"
      field(:access_token, String.t())
      field(:account_id, String.t())
      field(:email_address, String.t())
      field(:provider, list())
      field(:token_type, String.t())
    end

    typedstruct module: Options do
      @typedoc "Authentication options"
      field(:login_hint, String.t())
      field(:redirect_uri, String.t(), enforce: true)
      field(:state, String.t())
      field(:scopes, list())
      field(:response_type, String.t(), default: "code")
      field(:provider, String.t())
      field(:redirect_on_error, boolean())
    end

    def build_options(login_hint, redirect_uri, state, scopes, response_type, provider, redirect_on_error) do
      %Options{
        login_hint: login_hint,
        redirect_uri: redirect_uri,
        state: state,
        scopes: scopes,
        response_type: response_type,
        provider: provider,
        redirect_on_error: redirect_on_error
      }
    end

    @doc """
    Returns the URI to send the end user

    Notes:
      1. `client_id` is required (on the connection struct)
      2. `redirect_uri` is required (on the options map) and must be registered in the Nylas dashboard

    Example
        options = %{login_hint: "hello@nylas.com", redirect_uri: "https://mycoolapp.com/auth", state: "random string", scopes: ["email.read_only", "contacts.read_only", "calendar.read_only"]}
        {:ok, uri} = ExNylas.Authentication.Hosted.get_auth_url(conn, options)
    """
    def get_auth_url(%Conn{} = conn, options) do
      url =
        "#{conn.api_server}/oauth/authorize?client_id=#{conn.client_id}"
        |> parse_options(options)

      cond do
        Map.get(conn, :client_id) |> is_nil() ->
          {:error, "client_id on the connection struct is required for this call"}

        Map.get(options, :redirect_uri) |> is_nil() ->
          {:error, "redirect_uri was not found in the options map"}

        true ->
          {:ok, url}
      end
    end

    @doc """
    Returns the URI to send the end user

    Notes:
      1. `client_id` is required (on the connection struct)
      2. `redirect_uri` is required (on the options map) and must be registered in the Nylas dashboard

    Example
        options = %{login_hint: "hello@nylas.com", redirect_uri: "https://mycoolapp.com/auth", state: "random string", scopes: ["email.read_only", "contacts.read_only", "calendar.read_only"]}
        uri = ExNylas.Authentication.Hosted.get_auth_url!(conn, options)
    """
    def get_auth_url!(%Conn{} = conn, options) do
      case get_auth_url(conn, options) do
        {:ok, res} -> res
        {:error, reason} -> raise ExNylasError, reason
      end
    end

    @doc """
    Exchange an authorization code for a Nylas access token

    Example
        {:ok, access_token} = ExNylas.Authentication.Hosted.exchange_code_for_token(conn, code)
    """
    def exchange_code_for_token(%Conn{} = conn, code) do
      API.post(
        "#{conn.api_server}/oauth/token",
        %{
          client_id: conn.client_id,
          client_secret: conn.client_secret,
          grant_type: "authorization_code",
          code: code
        },
        ["content-type": "application/json"]
      )
      |> API.handle_response(ExNylas.Authentication)
    end

    @doc """
    Exchange an authorization code for a Nylas access token

    Example
        access_token = ExNylas.Authentication.Hosted.exchange_code_for_token!(conn, code)
    """
    def exchange_code_for_token!(%Conn{} = conn, code) do
      case exchange_code_for_token(conn, code) do
        {:ok, res} -> res
        {:error, reason} -> raise ExNylasError, reason
      end
    end

    # -- Private --
    defp parse_options(url, options) when is_struct(options) do
      st_options =
        options
        |> Map.from_struct()

      parse_options(url, st_options)
    end

    defp parse_options(url, options) do
      res =
        options
        |> Enum.map(fn {k, v} -> parse_options({k, v}) end)
        |> Enum.join()

      url <> res
    end

    defp parse_options({_key, nil}), do: ""

    defp parse_options({:scopes, scopes}) when is_list(scopes) do
      "&scopes=#{Enum.join(scopes, ",")}"
    end

    defp parse_options({key, val}), do: "&#{key}=#{val}"
  end

  defmodule ExNylas.Authentication.Native do
  @moduledoc """
  Nylas native authentication
  """

    use TypedStruct

    typedstruct do
      @typedoc "Native authentication response"
      field(:id, String.t())
      field(:object, String.t())
      field(:account_id, String.t())
      field(:name, String.t())
      field(:provider, String.t())
      field(:organization_unit, String.t())
      field(:sync_state, String.t())
      field(:linked_at, non_neg_integer)
      field(:email_address, String.t())
      field(:access_token, String.t())
      field(:billing_state, String.t())
    end

    typedstruct module: Settings do
      field(:google_client_id, String.t())
      field(:google_client_secret, String.t())
      field(:google_refresh_token, String.t())
      field(:microsoft_client_id, String.t())
      field(:microsoft_client_secret, String.t())
      field(:microsoft_refresh_token, String.t())
      field(:redirect_uri, String.t())
      field(:imap_host, String.t())
      field(:imap_port, non_neg_integer)
      field(:imap_username, String.t())
      field(:imap_password, String.t())
      field(:smtp_host, String.t())
      field(:smtp_port, non_neg_integer)
      field(:smtp_username, String.t())
      field(:smtp_password, String.t())
      field(:ssl_required, boolean())
      field(:password, String.t())
      field(:username, String.t())
      field(:exchange_server_host, String.t())
      field(:service_account, boolean())
      field(:service_account_json, String.t())
      field(:type, String.t())
      field(:project_id, String.t())
      field(:private_key_id, String.t())
      field(:private_key, String.t())
      field(:client_email, String.t())
      field(:client_id, String.t())
      field(:auth_uri, String.t())
      field(:token_uri, String.t())
      field(:auth_provider_x509_cert_url, String.t())
      field(:client_x509_cert_url, String.t())
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
      |> API.handle_response(ExNylas.Authentication.Native)
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
