defmodule ExNylas.Connection do
  @moduledoc """
  A struct representing a Nylas API connection.

  The client_id, client_secret and access_token are all optional when creating the connection struct.
  The API credentials that are required by the Nylas API varies, though for most calls to the Nylas API, the access_token is needed.
  For calls to account management and webhooks, the client_id and client_secret is required.

  """

  @api_server "https://api.nylas.com"
  @api_version "2.1"

  defstruct [:client_id, :client_secret, :access_token, api_server: @api_server, api_version: @api_version]
end
