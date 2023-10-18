defmodule ExNylas.Util.Providers do
  @moduledoc """
  Interface for Nylas providers.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Send a message.

  Example
      {:ok, sent_message} = conn |> ExNylas.Messages.send(`message`)
  """
  def detect(%Conn{} = conn, email, params \\ %{}) do
    params =
      params
      |> Map.merge(%{email: email, client_id: conn.client_id})
      |> Map.to_list()

    API.post(
      "#{conn.api_server}/v3/providers/detect",
      %{},
      API.header_bearer(conn),
      params
    )
    |> API.handle_response(ExNylas.Model.Provider)
  end

  @doc """
  Send a message.

  Example
      sent_message = conn |> ExNylas.Messages.send!(`message`)
  """
  def detect!(%Conn{} = conn, email, params \\ %{}) do
    case detect(conn, email, params) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

end
