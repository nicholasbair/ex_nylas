defmodule ExNylas.Authentication do
  @moduledoc """
  A struct and interface for Nylas hosted authentication
  """
  use TypedStruct

  typedstruct do
    @typedoc "Authentication options"
    field :login_hint,         String.t()
    field :redirect_uri,       String.t(), enforce: true
    field :state,              String.t()
    field :scopes,             list()
    field :response_type,      String.t(), default: "code"
    field :provider,           String.t()
    field :redirect_on_error?, boolean()
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

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
      "#{conn.api_server}/oauth/authorize?client_id=#{Map.get(conn, :client_id)}"
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
        {:ok, body}

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
  defp parse_options(url, options) do
    res =
      options
      |> Enum.map(fn {k, v} -> parse_options({k, v}) end)
      |> Enum.join()

    url <> res
  end

  defp parse_options({_key, nil}), do: ""
  defp parse_options({:scopes, scopes}) when is_list(scopes), do: "&scopes=#{Enum.join(scopes, ",")}"
  defp parse_options({key, val}), do: "&#{key}=#{val}"
end
