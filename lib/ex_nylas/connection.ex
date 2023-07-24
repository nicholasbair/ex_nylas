defmodule ExNylas.Connection do
  @moduledoc """
  A struct representing a Nylas API connection.

  The client_id, client_secret, api_key and grant_id are all optional when creating the connection struct.
  The API credentials that are required by the Nylas API varies, though for most calls to the Nylas API, the api_key and grant_id are needed.
  For calls to application, account management and webhooks, the client_id and client_secret is required.
  """

  @api_server "https://api.us.nylas.com"

  defstruct [
    :client_id,
    :client_secret,
    :api_key,
    :grant_id,
    api_server: @api_server
  ]

  @typedoc "A Nylas API connection."
  @type t :: %__MODULE__{
    client_id: String.t(),
    client_secret: String.t(),
    api_key: String.t(),
    grant_id: String.t(),
    api_server: String.t(),
  }

  @doc """
  Create a new Nylas connection.

  Example
      conn = ExNylas.Connection.new("client_id", "client_secret", "api_key", "grant_id")
  """
  def new(
        client_id,
        client_secret,
        api_key,
        grant_id,
        api_server \\ @api_server
      ) do
    %ExNylas.Connection{
      client_id: client_id,
      client_secret: client_secret,
      api_key: api_key,
      grant_id: grant_id,
      api_server: api_server
    }
  end
end
