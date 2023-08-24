defmodule ExNylas.Authentication.Hosted do
  @moduledoc """
  Nylas hosted authentication
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  defstruct [
    :access_token,
    :expires_in,
    :id_token,
    :refresh_token,
    :scope,
    :token_type,
    :grant_id,
  ]

  @type t :: %__MODULE__{
    access_token: String.t(),
    expires_in: integer(),
    id_token: String.t(),
    refresh_token: String.t(),
    scope: String.t(),
    token_type: String.t(),
    grant_id: String.t(),
  }

  def as_struct(), do: %ExNylas.Authentication.Hosted{}

  defmodule Options do
    @enforce_keys [:redirect_uri]
    defstruct [
      :provider,
      :redirect_uri,
      :scopes,
      :state,
      :login_hint,
      :access_type,
      :code_challenge,
      :code_challenge_method,
      :credential_id,
    ]

    @typedoc "Authentication options"
    @type t :: %__MODULE__{
      provider: String.t(),
      redirect_uri: String.t(),
      scopes: [String.t()],
      state: String.t(),
      login_hint: String.t(),
      access_type: String.t(),
      code_challenge: String.t(),
      code_challenge_method: String.t(),
      credential_id: String.t(),
    }
  end

  def build_options(provider, redirect_uri, scopes, state, login_hint, access_type, code_challenge, code_challenge_method, credential_id) do
    %Options{
      provider: provider,
      redirect_uri: redirect_uri,
      scopes: scopes,
      state: state,
      login_hint: login_hint,
      access_type: access_type,
      code_challenge: code_challenge,
      code_challenge_method: code_challenge_method,
      credential_id: credential_id,
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
      "#{conn.api_server}/v3/connect/auth?client_id=#{conn.client_id}"
      |> parse_options(options)

    cond do
      Map.get(conn, :client_id) |> is_nil() ->
        {:error, "client_id on the connection struct is required for this call"}

      Map.get(options, :redirect_uri) |> is_nil() ->
        {:error, "redirect_uri was not found in the options map"}

      Map.get(options, :response_type) |> is_nil() ->
        {:error, "response_type was not found in the options map"}

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
      {:ok, access_token} = ExNylas.Authentication.Hosted.exchange_code_for_token(conn, code, redirect)
  """
  def exchange_code_for_token(%Conn{} = conn, code, redirect_uri) do
    API.post(
      "#{conn.api_server}/v3/connect/token",
      %{
        client_id: conn.client_id,
        client_secret: conn.client_secret,
        grant_type: "authorization_code",
        code: code,
        redirect_uri: redirect_uri
      },
      ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Authentication.Hosted.as_struct(), false)
  end

  @doc """
  Exchange an authorization code for a Nylas access token

  Example
      access_token = ExNylas.Authentication.Hosted.exchange_code_for_token!(conn, code, redirect)
  """
  def exchange_code_for_token!(%Conn{} = conn, code, redirect_uri) do
    case exchange_code_for_token(conn, code, redirect_uri) do
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
    "&scope=#{Enum.join(scopes, ",")}"
  end

  defp parse_options({key, val}), do: "&#{key}=#{val}"
end