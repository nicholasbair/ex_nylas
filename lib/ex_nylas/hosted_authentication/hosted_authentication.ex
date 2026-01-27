defmodule ExNylas.HostedAuthentication do
  @moduledoc """
  Nylas hosted authentication

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/authentication-apis)
  """

  alias ExNylas.{
    API,
    Connection,
    Response,
    ResponseHandler,
    Telemetry
  }
  alias ExNylas.HostedAuthentication.Error, as: HAError
  alias ExNylas.HostedAuthentication.Grant, as: HA

  import ExNylas.Util, only: [indifferent_get: 2]

  use ExNylas,
    struct: ExNylas.HostedAuthentication.Options,
    readable_name: "hosted authentication",
    include: [:build]

  @doc """
  Returns the URI to send the end user

  Notes:
    1. `client_id` is required (on the connection struct)
    2. `redirect_uri` is required (in options) and must be registered on the Nylas application

  Optionally use ExNylas.HostedAuthentication.build/1 to validate options.

  ## Examples

      iex> options = %{login_hint: "hello@nylas.com", redirect_uri: "https://mycoolapp.com/auth", state: "random_string", scope: ["provider_scope_1", "provider_scope_2"]}
      iex> {:ok, uri} = ExNylas.HostedAuthentication.get_auth_url(conn, options)
  """
  @spec get_auth_url(Connection.t(), map() | Keyword.t()) :: {:ok, String.t()} | {:error, ExNylas.ValidationError.t()}
  def get_auth_url(%Connection{} = conn, options) do
    cond do
      is_nil(conn.client_id) ->
        {:error, ExNylas.ValidationError.exception({:client_id, "client_id on the connection struct is required for this call"})}

      indifferent_get(options, :redirect_uri) |> is_nil() ->
        {:error, ExNylas.ValidationError.exception({:redirect_uri, "redirect_uri was not found in the options map"})}

      indifferent_get(options, :response_type) |> is_nil() ->
        {:error, ExNylas.ValidationError.exception({:response_type, "response_type was not found in the options map"})}

      true ->
        {:ok,
         parse_options("#{conn.api_server}/v3/connect/auth?client_id=#{conn.client_id}", options)}
    end
  end

  @doc """
  Returns the URI to send the end user

  Notes:
    1. `client_id` is required (on the connection struct)
    2. `redirect_uri` is required (in options) and must be registered on the Nylas application

  Optionally use ExNylas.HostedAuthentication.build/1 to validate options.

  ## Examples

      iex> options = %{login_hint: "hello@nylas.com", redirect_uri: "https://mycoolapp.com/auth", state: "random_string", scope: ["provider_scope_1", "provider_scope_2"]}
      iex> uri = ExNylas.HostedAuthentication.get_auth_url!(conn, options)
  """
  @spec get_auth_url!(Connection.t(), map() | Keyword.t()) :: String.t()
  def get_auth_url!(%Connection{} = conn, options) do
    case get_auth_url(conn, options) do
      {:ok, res} -> res
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Exchange an authorization code for a Nylas access token

  ## Examples

      iex> {:ok, access_token} = ExNylas.HostedAuthentication.exchange_code_for_token(conn, code, redirect)
  """
  @spec exchange_code_for_token(Connection.t(), String.t(), String.t(), String.t()) ::
          {:ok, HA.t()}
          | {:error,
               Response.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()
               | HAError.t()}
  def exchange_code_for_token(
        %Connection{} = conn,
        code,
        redirect_uri,
        grant_type \\ "authorization_code"
      ) do
    Req.new(
      url: "#{conn.api_server}/v3/connect/token",
      headers: API.base_headers(),
      json: %{
        client_id: conn.client_id,
        client_secret: conn.api_key,
        grant_type: grant_type,
        code: code,
        redirect_uri: redirect_uri
      }
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> conditional_transform()
  end

  @doc """
  Exchange an authorization code for a Nylas access token

  ## Examples

      iex> access_token = ExNylas.HostedAuthentication.exchange_code_for_token!(conn, code, redirect)
  """
  @spec exchange_code_for_token!(Connection.t(), String.t(), String.t(), String.t()) :: HA.t()
  def exchange_code_for_token!(
        %Connection{} = conn,
        code,
        redirect_uri,
        grant_type \\ "authorization_code"
      ) do
    case exchange_code_for_token(conn, code, redirect_uri, grant_type) do
      {:ok, res} ->
        res

      {:error, %HAError{} = error} ->
        raise error

      {:error, exception} ->
        raise exception
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

  defp parse_options({key, val}), do: "&#{key}=#{URI.encode_www_form(to_string(val))}"

  # The response from the API differs based on whether the request was successful or not
  defp conditional_transform({:ok, %{status: 200}} = res) do
    ResponseHandler.handle_response(res, HA, false)
  end

  defp conditional_transform({:ok, %{body: body}}) when is_map(body) do
    # Error response - parse directly as HAError exception without Transform pipeline
    {:error, HAError.exception(body)}
  end

  defp conditional_transform(res) do
    # Other errors (network, etc.) go through normal error handling
    ResponseHandler.handle_response(res, nil, false)
  end
end
