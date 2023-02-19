defmodule ExNylas.DetectProvider do
  @moduledoc """
  A struct representing provider detection for a given email address.
  """
  use TypedStruct

  typedstruct do
    @typedoc "Detect provider"
    field(:auth_name, String.t())
    field(:detected, boolean())
    field(:email_address, String.t())
    field(:is_imap, boolean())
    field(:provider_name, String.t())
  end

  typedstruct module: Build, enforce: true do
    @typedoc "A struct representing the detect provider request payload"
    field(:client_id, String.t())
    field(:client_secret, String.t())
    field(:email_address, String.t())
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Detect the provider for a given email address.

  Example
      {:ok, result} = conn |> ExNylas.DetectProvider.detect(`email_address`)
  """
  def detect(%Conn{} = conn, email_address) do
    API.post(
      "#{conn.api_server}/connect/detect-provider",
      %ExNylas.DetectProvider.Build{
        client_id: conn.client_id,
        client_secret: conn.client_secret,
        email_address: email_address
      },
      "content-type": "application/json"
    )
    |> API.handle_response(__MODULE__)
  end

  @doc """
  Detect the provider for a given email address.

  Example
      result = conn |> ExNylas.DetectProvider.detect!(`email_address`)
  """
  def detect!(%Conn{} = conn, email_address) do
    case detect(conn, email_address) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
