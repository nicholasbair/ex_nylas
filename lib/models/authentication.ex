defmodule ExNylas.Authentication do
  @moduledoc """
  A struct and interface for Nylas hosted authentication
  """
  use TypedStruct

  typedstruct do
    @typedoc "Authentication options"
    field :login_hint,   String.t()
    field :redirect_uri, String.t()
    field :state,        String.t()
    field :scopes,       list()
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Returns the URI to send the end user

  Notes:
    1. `client_id` is required (on the connection struct)
    2. `login_hint` is required (on the options map) and should be an email

  Example
      options = %{login_hint: "hello@nylas.com", redirect_uri: "https://mycoolapp.com/auth", state: "random string", scopes: ["email.read_only", "contacts.read_only", "calendar.read_only"]}
      {:ok, uri} = ExNylas.Authentication.get_auth_url(conn, options)
  """
  def get_auth_url(%Conn{} = conn, options) do
    url =
      "#{conn.api_server}/oauth/authorize?client_id=#{Map.get(conn, :client_id)}&response_type=code&login_hint=#{Map.get(options, :login_hint)}&redirect_uri=#{Map.get(options, :redirect_uri)}"
      |> parse_state(options)
      |> parse_scopes(options)

    cond do
      Map.get(conn, :client_id) |> is_nil() ->
        {:error, "client_id on the connection struct is required for this call"}

      Map.get(options, :login_hint) |> is_nil() ->
        {:error, "login_hint was not found in the options map"}

      true ->
        {:ok, url}
    end
  end

  @doc """
  Returns the URI to send the end user

  Notes:
    1. `client_id` is required (on the connection struct)
    2. `login_hint` is required (on the options map) and should be an email

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

      # The API returns HTML here
      {:ok, %HTTPoison.Response{body: _body}} ->
        {:error, "An error occurred, did not recieve an access token"}

      {:error, %HTTPoison.Error{reason: _reason}} ->
        {:error, "An error occurred, did not recieve an access token"}
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
      {:error, _reason} -> raise ExNylasError, "An error occurred, did not recieve an access token"
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
        {:ok, TF.transform(body, Group)}

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
  defp parse_state(url, %{state: nil}), do: url
  defp parse_state(url, %{state: state}), do: url <> "&state=#{state}"
  defp parse_state(url, _), do: url

  defp parse_scopes(url, %{scopes: nil}), do: url
  defp parse_scopes(url, %{scopes: scopes}) when is_list(scopes), do: url <> "&scopes=#{Enum.join(scopes, ",")}"
  defp parse_scopes(url, %{scopes: scopes}), do: url <> "&scopes=#{scopes}"

end
