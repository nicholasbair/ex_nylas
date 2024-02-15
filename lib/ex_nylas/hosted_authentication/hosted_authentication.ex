defmodule ExNylas.HostedAuthentication do
  @moduledoc """
  Nylas hosted authentication
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.HostedAuthentication.Grant, as: HA

  use ExNylas,
    struct: ExNylas.HostedAuthentication.Options,
    readable_name: "hosted authentication",
    include: [:build]

  @doc """
  Returns the URI to send the end user

  Notes:
    1. `client_id` is required (on the connection struct)
    2. `redirect_uri` is required (on the options map) and must be registered on the Nylas application
    3. `response_type` is required (on the options map)

  Optionally use ExNylas.HostedAuthentication.build/1 to validate the options map.

  ## Examples

      iex> options = %{login_hint: "hello@nylas.com", redirect_uri: "https://mycoolapp.com/auth", state: "random_string", scope: ["provider_scope_1", "provider_scope_2"]}
      iex> {:ok, uri} = ExNylas.HostedAuthentication.get_auth_url(conn, options)
  """
  def get_auth_url(%Conn{} = conn, options) do
    cond do
      Map.get(conn, :client_id) |> is_nil() ->
        {:error, "client_id on the connection struct is required for this call"}

      Map.get(options, :redirect_uri) |> is_nil() ->
        {:error, "redirect_uri was not found in the options map"}

      Map.get(options, :response_type) |> is_nil() ->
        {:error, "response_type was not found in the options map"}

      true ->
        {:ok, parse_options("#{conn.api_server}/v3/connect/auth?client_id=#{conn.client_id}", options)}
    end
  end

  @doc """
  Returns the URI to send the end user

  Notes:
    1. `client_id` is required (on the connection struct)
    2. `redirect_uri` is required (on the options map) and must be registered on the Nylas application
    3. `response_type` is required (on the options map)

  Optionally use ExNylas.HostedAuthentication.build/1 to validate the options map.

  ## Examples

      iex> options = %{login_hint: "hello@nylas.com", redirect_uri: "https://mycoolapp.com/auth", state: "random_string", scope: ["provider_scope_1", "provider_scope_2"]}
      iex> uri = ExNylas.HostedAuthentication.get_auth_url!(conn, options)
  """
  def get_auth_url!(%Conn{} = conn, options) do
    case get_auth_url(conn, options) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Exchange an authorization code for a Nylas access token

  ## Examples

      iex> {:ok, access_token} = ExNylas.HostedAuthentication.exchange_code_for_token(conn, code, redirect)
  """
  def exchange_code_for_token(%Conn{} = conn, code, redirect_uri, grant_type \\ "authorization_code") do
    Req.new(
      url: "#{conn.api_server}/v3/connect/token",
      headers: API.base_headers(),
      json: %{
        client_id: conn.client_id,
        client_secret: conn.client_secret,
        grant_type: grant_type,
        code: code,
        redirect_uri: redirect_uri
      }
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(HA, false)
  end

  @doc """
  Exchange an authorization code for a Nylas access token

  ## Examples

      iex> access_token = ExNylas.HostedAuthentication.exchange_code_for_token!(conn, code, redirect)
  """
  def exchange_code_for_token!(%Conn{} = conn, code, redirect_uri, grant_type \\ "authorization_code") do
    case exchange_code_for_token(conn, code, redirect_uri, grant_type) do
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
      |> Enum.map_join(fn {k, v} -> parse_options({k, v}) end)

    url <> res
  end

  defp parse_options({_key, nil}), do: ""

  defp parse_options({:scope, scope}) when is_list(scope) do
    "&scope=#{Enum.join(scope, ",")}"
  end

  defp parse_options({key, val}), do: "&#{key}=#{val}"
end
