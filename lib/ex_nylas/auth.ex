defmodule ExNylas.Auth do
  @moduledoc false

  alias ExNylas.Connection, as: Conn

  @spec auth_bearer(Conn.t()) :: {:bearer, String.t()}
  def auth_bearer(%Conn{grant_id: "me", access_token: access_token}) when is_nil(access_token) do
    raise ExNylasError, "access_token must be present when using grant_id='me'"
  end

  def auth_bearer(%Conn{grant_id: "me", access_token: access_token}) do
    {:bearer, access_token}
  end

  def auth_bearer(%Conn{api_key: api_key}) when is_nil(api_key) do
    raise ExNylasError, "missing value for api_key"
  end

  def auth_bearer(%Conn{api_key: api_key}) do
    {:bearer, api_key}
  end
end
