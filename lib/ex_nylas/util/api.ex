defmodule ExNylas.API do
  @moduledoc """
  Wrapper for HTTPoison, handles making HTTP requests, encoding requests, and decoding responses
  """

  use HTTPoison.Base
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  @base_headers [
    accept: "application/json",
    "user-agent": "ExNylas/" <> Mix.Project.config()[:version]
  ]

  @success_codes Enum.to_list(200..299)

  def process_request_body({:ok, body}) when is_map(body) or is_struct(body),
    do: Poison.encode!(body)

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
      "Nylas-API-Version": conn.api_version
    ] ++ @base_headers
  end

  def header_basic(%Conn{} = conn) do
    encoded = Base.encode64("#{conn.client_secret}:")

    [
      authorization: "Basic #{encoded}",
      "Nylas-API-Version": conn.api_version
    ] ++ @base_headers
  end

  def header_basic(auth_val, api_version) do
    encoded = Base.encode64("#{auth_val}:")

    [
      authorization: "Basic #{encoded}",
      "Nylas-API-Version": api_version
    ] ++ @base_headers
  end

  def handle_response(res, transform_to \\ nil) do
    response_handler(res, transform_to)
  end

  defp response_handler(res, transform_to) when is_nil(transform_to) do
    case res do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        case status do
          status when status in @success_codes ->
            {:ok, body}

          _ ->
            {:error, body}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp response_handler(res, transform_to) do
    case response_handler(res, nil) do
      {:ok, body} ->
        {:ok, TF.transform(body, transform_to)}

      body -> body
    end
  end
end
