defmodule ExNylas.API do
  @moduledoc """
  Wrapper for HTTPoison, handles making HTTP requests, encoding requests, and decoding responses
  """

  use HTTPoison.Base
  alias ExNylas.Connection, as: Conn

  @base_headers [
    accept: "application/json",
    "user-agent": "ExNylas/" <> Mix.Project.config()[:version]
  ]

  def process_request_body({:ok, body}) when is_map(body) or is_struct(body), do: Poison.encode!(body)

  def process_request_body(body) when is_map(body) or is_struct(body), do: Poison.encode!(body)

  def process_request_body(body), do: body

  def process_response_body(body) do
    case Poison.decode(body) do
      {:ok, res} -> res
      {:error, _} -> body
    end
  end

  def header_bearer(%Conn{} = conn) do
    [
      authorization: "Bearer #{conn.access_token}",
      "Nylas-API-Version": conn.api_version,
    ] ++ @base_headers
  end

  def header_basic(%Conn{} = conn) do
    encoded = Base.encode64("#{conn.client_secret}:")

    [
      authorization: "Basic #{encoded}",
      "Nylas-API-Version": conn.api_version,
    ] ++ @base_headers
  end

  def header_basic(auth_val, api_version) do
    encoded = Base.encode64("#{auth_val}:")

    [
      authorization: "Basic #{encoded}",
      "Nylas-API-Version": api_version,
    ] ++ @base_headers
  end
end
