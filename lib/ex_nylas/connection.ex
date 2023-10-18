defmodule ExNylas.Connection do
   @moduledoc """
  A struct representing a Nylas API connection.

  The client_id, client_secret, api_key and grant_id are all optional when creating the connection struct.
  The API credentials that are required by the Nylas API varies, though for most calls to the Nylas API, the api_key and grant_id are needed.
  For calls to application, account management and webhooks, the client_id and client_secret is required.
  """

  use TypedStruct

  @api_server "https://api.us.nylas.com"

  typedstruct do
    field(:client_id, String.t())
    field(:client_secret, String.t())
    field(:api_key, String.t())
    field(:grant_id, String.t())
    field(:api_server, String.t(), default: @api_server)
  end
end
