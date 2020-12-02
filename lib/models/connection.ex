defmodule ExNylas.Connection do
  @moduledoc """
  A struct representing a Nylas API connection.

  The client_id, client_secret and access_token are all optional when creating the connection struct.
  The API credentials that are required by the Nylas API varies, though for most calls to the Nylas API, the access_token is needed.
  For calls to application, account management and webhooks, the client_id and client_secret is required.
  """

  @api_server "https://api.nylas.com"
  @api_version "2.1"

  defstruct [:client_id, :client_secret, :access_token, api_server: @api_server, api_version: @api_version]

  @doc """
  Create a new Nylas connection.

  Example
      conn = ExNylas.Connection.new("id", "secret", "token")
  """
  def new(client_id, client_secret, access_token) do
    %ExNylas.Connection{
      client_id: client_id,
      client_secret: client_secret,
      access_token: access_token
    }
  end

end
