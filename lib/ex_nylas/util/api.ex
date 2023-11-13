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

  def process_request_body({:ok, body}) when is_map(body) or is_struct(body), do: Poison.encode!(body)

  def process_request_body(body) when is_map(body) or is_struct(body), do: Poison.encode!(body)

  # Encoding for multipart bodies is handled in the interface module, e.g. ExNylas.Messages or ExNylas.Common
  def process_request_body({:multipart, _} = body), do: body

  def process_request_body(body), do: body

  def header_bearer(%Conn{access_token: token, grant_id: grant_id}) when not is_nil(token) and is_nil(grant_id) do
    raise "ExNylas.Connection struct is missing a value for `access_token` or `grant_id` which are required for this call."
  end

  def header_bearer(%Conn{access_token: access_token} = _conn) when not is_nil(access_token) do
    [
      authorization: "Bearer #{access_token}"
    ] ++ @base_headers
  end

  def header_bearer(%Conn{api_key: key, grant_id: grant_id}) when is_nil(key) or is_nil(grant_id) do
    raise "ExNylas.Connection struct is missing a value for `api_key` or `grant_id` which are required for this call."
  end

  def header_bearer(%Conn{} = conn) do
    [
      authorization: "Bearer #{conn.api_key}"
    ] ++ @base_headers
  end

  def header_api_key(%Conn{api_key: key}) when is_nil(key) do
    raise "ExNylas.Connection struct is missing a value for `api_key` which is required for this call."
  end

  def header_api_key(%Conn{} = conn) do
    [
      authorization: "Bearer #{conn.api_key}"
    ] ++ @base_headers
  end

  def header_basic(%Conn{client_id: id, client_secret: secret}) when is_nil(id) or is_nil(secret) do
    raise "ExNylas.Connection struct is missing a value for `client_id` or `client_secret` which are required for this call."
  end

  def header_basic(%Conn{} = conn) do
    encoded = Base.encode64("#{conn.client_id}:#{conn.client_secret}")

    [
      authorization: "Basic #{encoded}"
    ] ++ @base_headers
  end

  def handle_response(res, transform_to \\ nil, use_common_response \\ true)
  def handle_response(res, transform_to, _) when is_nil(transform_to) do
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

      _ -> res
    end
  end

  def handle_response(res, transform_to, true = _use_common_response) do
    case handle_response(res, nil) do
      {:ok, body} ->
        TF.transform(body, ExNylas.Model.Common.Response.as_struct(transform_to))

      {:error, :timeout} ->
        {:error, :timeout}

      {:error, body} ->
        # transform returns ok tuple if transforming to struct succeeds, even if its an error struct
        {_, val} = TF.transform(body, ExNylas.Model.Common.Response.as_struct(transform_to))
        {:error, val}
    end
  end

  def handle_response(res, transform_to, false = _use_common_response) do
    case handle_response(res, nil) do
      {:ok, body} -> TF.transform(body, transform_to)
      body -> body
    end
  end
end
