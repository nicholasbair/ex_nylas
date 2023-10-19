defmodule ExNylas.SmartCompose do
  @moduledoc """
  Interface for Nylas smart compose.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  use ExNylas,
    object: "messages/smart-compose",
    struct: ExNylas.Model.SmartCompose,
    include: [:build, :create]

  @doc """
  Smart compose a message reply.

  Example
      {:ok, res} = conn |> ExNylas.create_reply(`message_id`, `prompt`)
  """
  def create_reply(%Conn{} = conn, message_id, prompt) do
    API.post(
      "#{conn.api_server}/v3/messages/#{message_id}/smart-compose",
      %{prompt: prompt},
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(ExNylas.Model.SmartCompose)
  end

  @doc """
  Smart compose a message reply.

  Example
      res = conn |> ExNylas.create_reply!(`message_id`, `prompt`)
  """
  def create_reply!(%Conn{} = conn, message_id, prompt) do
    case create_reply(conn, message_id, prompt) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end