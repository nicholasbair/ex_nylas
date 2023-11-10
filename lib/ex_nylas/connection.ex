defmodule ExNylas.Connection do
   @moduledoc """
  A struct representing a Nylas API connection.

  The client_id, client_secret, api_key and grant_id are all optional when creating the connection struct.
  The API credentials that are required by the Nylas API varies, though for most calls to the Nylas API, the api_key and grant_id are needed.
  For calls to application, account management and webhooks, the client_id and client_secret is required.
  """

  use TypedStruct

  @api_server "https://api.us.nylas.com"
  @timeout 3_000
  @recv_timeout 5_000

  typedstruct do
    field(:client_id, String.t())
    field(:client_secret, String.t())
    field(:api_key, String.t())
    field(:grant_id, String.t())
    field(:access_token, String.t())
    field(:api_server, String.t(), default: @api_server)
    field(:timeout, non_neg_integer(), default: @timeout) # timeout for establishing a TCP or SSL connection, in milliseconds.
    field(:recv_timeout, non_neg_integer(), default: @recv_timeout) # timeout for receiving an HTTP response from the socket, in milliseconds.
  end
end
