defmodule ExNylas.Connection do
  @moduledoc """
  A struct representing a Nylas API connection.

  The client_id, client_secret, api_key and grant_id are all optional when creating the connection struct.
  The API credentials that are required by the Nylas API varies, though for most calls to the Nylas API the api_key and grant_id are needed.
  """

  defstruct [
    :client_id,
    :client_secret,
    :api_key,
    :grant_id,
    :access_token,
    api_server: "https://api.us.nylas.com",

    # Pass in a list of options to be used when making the request, e.g. `receive_timeout`, `retry`.
    # These options are passed directly to the `Req` library.
    # See https://hexdocs.pm/req/Req.html#new/1 for more information.
    options: [],
    telemetry: false
  ]
end
