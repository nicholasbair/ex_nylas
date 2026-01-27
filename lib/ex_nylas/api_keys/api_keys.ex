defmodule ExNylas.APIKeys do
  @moduledoc """
  Interface for Nylas API keys.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/manage-api-keys)
  """

  alias ExNylas.{
    API,
    APIKey,
    Connection,
    Response,
    ResponseHandler,
    Telemetry
  }

  @doc"""
  Create an API key for an application.

  ## Examples

      iex> {:ok, result} = ExNylas.APIKeys.create(conn, "application_id", %{name: "My API Key", expires_in: 90  }, "signature", "kid", "nonce", "timestamp")
  """
  @spec create(Connection.t(), String.t(), map(), String.t(), String.t(), String.t(), String.t()) ::
    {:ok, Response.t()} | {:error, Response.t()}
  def create(%Connection{} = conn, application_id, body, signature, kid, nonce, timestamp) do
    Req.new(
      url: "#{conn.api_server}/v3/admin/applications/#{application_id}/api-keys",
      headers: build_headers(signature, kid, nonce, timestamp),
      json: body
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(APIKey)
  end

  @doc"""
  Create an API key for an application.

  ## Examples

      iex> result = ExNylas.APIKeys.create!(conn, "application_id", %{name: "My API Key", expires_in: 90}, "signature", "kid", "nonce", "timestamp")
  """
  @spec create!(Connection.t(), String.t(), map(), String.t(), String.t(), String.t(), String.t()) ::
    Response.t()
  def create!(%Connection{} = conn, application_id, body, signature, kid, nonce, timestamp) do
    case create(conn, application_id, body, signature, kid, nonce, timestamp) do
      {:ok, response} ->
        response

      {:error, %ExNylas.Response{error: %ExNylas.APIError{} = error}} ->
        raise error

      {:error, %ExNylas.Response{} = resp} ->
        raise ExNylas.APIError.exception(%{message: "API request failed with status #{resp.status}"})

      {:error, exception} ->
        raise exception
    end
  end

  @doc"""
  List API keys for an application.

  ## Examples

      iex> {:ok, result} = ExNylas.APIKeys.list(conn, "application_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec list(Connection.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    {:ok, Response.t()} | {:error, Response.t()}
  def list(%Connection{} = conn, application_id, signature, kid, nonce, timestamp) do
    Req.new(
      url: "#{conn.api_server}/v3/admin/applications/#{application_id}/api-keys",
      headers: build_headers(signature, kid, nonce, timestamp)
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> ResponseHandler.handle_response(APIKey)
  end

  @doc"""
  List API keys for an application.

  ## Examples

      iex> result = ExNylas.APIKeys.list!(conn, "application_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec list!(Connection.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    Response.t()
  def list!(%Connection{} = conn, application_id, signature, kid, nonce, timestamp) do
    case list(conn, application_id, signature, kid, nonce, timestamp) do
      {:ok, response} ->
        response

      {:error, %ExNylas.Response{error: %ExNylas.APIError{} = error}} ->
        raise error

      {:error, %ExNylas.Response{} = resp} ->
        raise ExNylas.APIError.exception(%{message: "API request failed with status #{resp.status}"})

      {:error, exception} ->
        raise exception
    end
  end

  @doc"""
  Find an API key for an application.

  ## Examples

      iex> {:ok, result} = ExNylas.APIKeys.find(conn, "application_id", "api_key_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec find(Connection.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    {:ok, Response.t()} | {:error, Response.t()}
  def find(%Connection{} = conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
    Req.new(
      url: "#{conn.api_server}/v3/admin/applications/#{application_id}/api-keys/#{api_key_id}",
      headers: build_headers(signature, kid, nonce, timestamp)
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> ResponseHandler.handle_response(APIKey)
  end

  @doc"""
  Find an API key for an application.

  ## Examples

      iex> result = ExNylas.APIKeys.find!(conn, "application_id", "api_key_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec find!(Connection.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    Response.t()
  def find!(%Connection{} = conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
    case find(conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
      {:ok, response} ->
        response

      {:error, %ExNylas.Response{error: %ExNylas.APIError{} = error}} ->
        raise error

      {:error, %ExNylas.Response{} = resp} ->
        raise ExNylas.APIError.exception(%{message: "API request failed with status #{resp.status}"})

      {:error, exception} ->
        raise exception

    end
  end

  @doc"""
  Delete an API key for an application.

  ## Examples

      iex> {:ok, result} = ExNylas.APIKeys.delete(conn, "application_id", "api_key_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec delete(Connection.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    {:ok, Response.t()} | {:error, Response.t()}
  def delete(%Connection{} = conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
    Req.new(
      url: "#{conn.api_server}/v3/admin/applications/#{application_id}/api-keys/#{api_key_id}",
      headers: build_headers(signature, kid, nonce, timestamp)
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.delete(conn.options)
    |> ResponseHandler.handle_response(APIKey)
  end

  @doc"""
  Delete an API key for an application.

  ## Examples

      iex> result = ExNylas.APIKeys.delete!(conn, "application_id", "api_key_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec delete!(Connection.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    Response.t()
  def delete!(%Connection{} = conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
    case delete(conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
      {:ok, response} ->
        response

      {:error, %ExNylas.Response{error: %ExNylas.APIError{} = error}} ->
        raise error

      {:error, %ExNylas.Response{} = resp} ->
        raise ExNylas.APIError.exception(%{message: "API request failed with status #{resp.status}"})

      {:error, exception} ->
        raise exception

    end
  end

  @spec build_headers(String.t(), String.t(), String.t(), String.t()) :: Keyword.t()
  defp build_headers(signature, kid, nonce, timestamp) do
    [
      {:"X-Nylas-Signature", signature},
      {:"X-Nylas-Kid", kid},
      {:"X-Nylas-Nonce", nonce},
      {:"X-Nylas-Timestamp", timestamp}
    ]
    |> API.base_headers()
  end
end
