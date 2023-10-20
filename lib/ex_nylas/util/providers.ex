defmodule ExNylas.Providers do
  @moduledoc """
  Interface for Nylas providers.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Detect the provider for an email address.

  Example
      {:ok,  detect} = conn |> ExNylas.Providers.detect(%{email: `email`} = _params)
  """
  def detect(%Conn{} = conn, params \\ %{}) do
    url = "#{conn.api_server}/v3/providers/detect?#{URI.encode_query(params)}"

    API.post(
      url,
      %{},
      API.header_bearer(conn),
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(ExNylas.Model.Provider)
  end

  @doc """
  Detect the provider for an email address.

  Example
      detect = conn |> ExNylas.Providers.detect(%{email: `email`} = _params)
  """
  def detect!(%Conn{} = conn, params \\ %{}) do
    case detect(conn, params) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

end
