defmodule ExNylas.Authentication.Hosted do
  @moduledoc """
  Nylas hosted authentication
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  defstruct [
    :url,
    :id,
    :expires_at,
    :request
  ]

  @type t :: %__MODULE__{
    url: String.t(),
    id: String.t(),
    expires_at: integer(),
    request: Map.t(),
  }

  def as_struct(), do: %ExNylas.Authentication.Hosted{}

  defmodule Options do
    @enforce_keys [:provider, :redirect_uri]
    defstruct [
      :provider,
      :redirect_uri,
      :settings,
      :scope,
      :grant_id,
      :login_hint,
      :state,
      :expires_in,
      :cookie_nonce,
    ]

    @typedoc "Authentication options"
    @type t :: %__MODULE__{
      provider: String.t(),
      redirect_uri: String.t(),
      settings: Map.t(),
      scope: [String.t()],
      grant_id: String.t(),
      login_hint: String.t(),
      state: String.t(),
      expires_in: integer(),
      cookie_nonce: String.t(),
    }
  end

  def build_options(provider, redirect_uri, settings, scope, grant_id, login_hint, state, expires_in, cookie_nonce) do
    %Options{
      provider: provider,
      redirect_uri: redirect_uri,
      settings: settings,
      scope: scope,
      grant_id: grant_id,
      login_hint: login_hint,
      state: state,
      expires_in: expires_in,
      cookie_nonce: cookie_nonce,
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
    API.post(
    "#{conn.api_server}/v3/connect/auth",
    options,
    API.header_api_key(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(as_struct())
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
      {:error, res} -> raise ExNylasError, res.error.message
    end
  end
end
