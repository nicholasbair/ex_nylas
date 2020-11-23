defmodule ExNylas.Account do
  @moduledoc """
  A struct representing an account & interface for Nylas account.
  """
  use TypedStruct

  typedstruct do
    @typedoc "An account"
    field :id,                String.t()
    field :account_id,        String.t()
    field :object,            String.t()
    field :name,              String.t()
    field :email_address,     String.t()
    field :provider,          String.t()
    field :organization_unit, String.t()
    field :sync_state,        String.t()
    field :linked_at,         String.t()
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  def get(%Conn{} = conn) do
    res =
      API.get(
        "#{conn.api_server}/account",
        API.header_bearer(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.Account)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def get!(%Conn{} = conn) do
    case get(conn) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

end
