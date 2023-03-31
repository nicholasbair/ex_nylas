defmodule ExNylas.Application do
  @moduledoc """
  A struct representing a Nylas application.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  defstruct [:application_name, :icon_url, :redirect_uris]

  @type t :: %__MODULE__{
    application_name: String.t(),
    icon_url: String.t(),
    redirect_uris: [String.t()]
  }

  def as_struct(), do: %ExNylas.Application{}

  @doc """
  Get the application.

  Example
      {:ok, result} = conn |> ExNylas.Application.get()
  """
  def get(%Conn{} = conn) do
    API.get(
      "#{conn.api_server}/a/#{conn.client_id}",
      API.header_basic(conn)
    )
    |> API.handle_response(as_struct())
  end

  @doc """
  Get the application.

  Example
      result = conn |> ExNylas.Application.get!()
  """
  def get!(%Conn{} = conn) do
    case get(conn) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Update the application.

  Example
      {:ok, result} = conn |> ExNylas.Application.update(`body`)
  """
  def update(%Conn{} = conn, body) do
    API.put(
      "#{conn.api_server}/a/#{conn.client_id}",
      body,
      API.header_basic(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(as_struct())
  end

  @doc """
  Update the application.

  Example
      result = conn |> ExNylas.Application.update!(`body`)
  """
  def update!(%Conn{} = conn, body) do
    case update(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
