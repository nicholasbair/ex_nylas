defmodule ExNylas.Application do
  @moduledoc """
  A struct representing a Nylas application.
  """
  use TypedStruct

  typedstruct do
    field :application_name, String.t()
    field :icon_url,         String.t()
    field :redirect_uris,    list()
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  def get(%Conn{} = conn) do
    res =
      API.get(
        "#{conn.api_server}/a/#{conn.client_id}",
        API.header_basic(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.Application)}

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

  def update(%Conn{} = conn, body) do
    res =
      API.put(
        "#{conn.api_server}/a/#{conn.client_id}",
        API.header_basic(conn),
        body
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.Application)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def update!(%Conn{} = conn, body) do
    case update(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

end
