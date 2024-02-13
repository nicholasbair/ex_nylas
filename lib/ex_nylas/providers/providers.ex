defmodule ExNylas.Providers do
  @moduledoc """
  Interface for Nylas providers.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Provider

  @doc """
  Detect the provider for an email address.

  ## Examples

      iex> {:ok,  detect} = ExNylas.Providers.detect(conn, %{email: email} = _params)
  """
  def detect(%Conn{} = conn, params \\ %{}) do
    Req.new(
      url: "#{conn.api_server}/v3/providers/detect",
      auth: API.auth_bearer(conn),
      headers: API.base_headers(),
      params: params
    )
    |> Req.post(conn.options)
    |> API.handle_response(Provider)
  end

  @doc """
  Detect the provider for an email address.

  ## Examples

      iex> detect = ExNylas.Providers.detect(conn, %{email: email} = _params)
  """
  def detect!(%Conn{} = conn, params \\ %{}) do
    case detect(conn, params) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
