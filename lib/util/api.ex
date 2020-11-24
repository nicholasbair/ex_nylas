defmodule ExNylas.API do
  @moduledoc """
  Wrapper for HTTPoison, handles making HTTP requests, encoding requests, and decoding responses
  """

  use HTTPoison.Base
  alias ExNylas.Connection, as: Conn

  def process_request_body(body) when is_map(body), do: Jason.encode!(body)
  def process_request_body(body) when is_struct(body) do
    body
    |> Map.from_struct()
    |> Jason.encode!()
  end
  def process_request_body(body), do: body

  def process_response_body(body) do
    case Jason.decode(body) do
      {:ok, res} -> res
      {:error, _} -> body
    end
  end

  def header_bearer(%Conn{} = conn), do: [authorization: "Bearer #{conn.access_token}", "Nylas-API-Version": conn.api_version]
  def header_basic(%Conn{} = conn) do
    encoded = Base.encode64("#{conn.client_secret}:")
    [authorization: "Basic #{encoded}", "Nylas-API-Version": conn.api_version]
  end

end
