defmodule ExNylas.Authentication do

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  use TypedStruct

  typedstruct do
    @typedoc "Authentication response"
    field(:access_token, String.t())
    field(:account_id, String.t())
    field(:email_address, String.t())
    field(:provider, list())
    field(:token_type, String.t())
  end

  defmodule Options do
    @moduledoc """
    A struct and interface for Nylas hosted authentication
    """
    use TypedStruct

    typedstruct do
      @typedoc "Authentication options"
      field(:login_hint, String.t())
      field(:redirect_uri, String.t(), enforce: true)
      field(:state, String.t())
      field(:scopes, list())
      field(:response_type, String.t(), default: "code")
      field(:provider, String.t())
      field(:redirect_on_error, boolean())
    end

    def new(login_hint, redirect_uri, state, scopes, response_type, provider, redirect_on_error) do
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
  end

  @doc """
  Returns the URI to send the end user

  Notes:
    1. `client_id` is required (on the connection struct)
    2. `redirect_uri` is required (on the options map) and must be registered in the Nylas dashboard

  Example
      options = %{login_hint: "hello@nylas.com", redirect_uri: "https://mycoolapp.com/auth", state: "random string", scopes: ["email.read_only", "contacts.read_only", "calendar.read_only"]}
      {:ok, uri} = ExNylas.Authentication.get_auth_url(conn, options)
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
      uri = ExNylas.Authentication.get_auth_url!(conn, options)
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
      {:ok, access_token} = ExNylas.Authentication.exchange_code_for_token(conn, code)
  """
  def exchange_code_for_token(%Conn{} = conn, code) do
    res =
      API.post(
        "#{conn.api_server}/oauth/token",
        %{
          client_id: conn.client_id,
          client_secret: conn.client_secret,
          grant_type: "authorization_code",
          code: code
        },
        API.header_basic(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, __MODULE__)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Exchange an authorization code for a Nylas access token

  Example
      access_token = ExNylas.Authentication.exchange_code_for_token!(conn, code)
  """
  def exchange_code_for_token!(%Conn{} = conn, code) do
    case exchange_code_for_token(conn, code) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Revoke an access token

  Example
      {:ok, res} = ExNylas.Authentication.revoke_token(conn)
  """
  def revoke_token(%Conn{} = conn) do
    res =
      API.post(
        "#{conn.api_server}/oauth/revoke",
        %{},
        API.header_basic(conn.access_token, conn.api_version)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
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
