# defmodule ExNylas.Accounts do
#   @moduledoc """

#   """

#   # TODO:
#   # Should this be using client secret instead?

#   alias ExNylas.Http
#   alias ExNylas.Connection, as: Conn

#   def list(%Conn{} = conn) do
#     Http.get("#{conn.api_server}/account", conn.access_token, conn.api_version)
#   end

#   def list!(%Conn{} = conn) do
#     case list(conn) do
#       {:ok, body} -> body
#       {:error, reason} -> raise ExNylasError, reason
#     end
#   end

# end
