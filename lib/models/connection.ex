defmodule ExNylas.Connection do
  @api_server "https://api.nylas.com"
  @api_version "2.1"

  defstruct [:client_id, :client_secret, :access_token, api_server: @api_server, api_version: @api_version]
end
