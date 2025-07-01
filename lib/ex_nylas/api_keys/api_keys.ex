defmodule ExNylas.APIKeys do
  @moduledoc """
  Interface for Nylas API keys.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/manage-api-keys)
  """

  alias ExNylas.API
  alias ExNylas.APIKey
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Response

  @doc"""
  Create an API key for an application.

  ## Examples

      iex> {:ok, result} = ExNylas.APIKeys.create(conn, "application_id", %{name: "My API Key", expires_in: 90  }, "signature", "kid", "nonce", "timestamp")
  """
  @spec create(Conn.t(), String.t(), map(), String.t(), String.t(), String.t(), String.t()) ::
    {:ok, Response.t()} | {:error, Response.t()}
  def create(%Conn{} = conn, application_id, body, signature, kid, nonce, timestamp) do
    Req.new(
      url: "#{conn.api_server}/v3/admin/applications/#{application_id}/api-keys",
      headers: build_headers(signature, kid, nonce, timestamp),
      json: body
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(APIKey)
  end

  @doc"""
  Create an API key for an application.

  ## Examples

      iex> result = ExNylas.APIKeys.create!(conn, "application_id", %{name: "My API Key", expires_in: 90  }, "signature", "kid", "nonce", "timestamp")
  """
  @spec create!(Conn.t(), String.t(), map(), String.t(), String.t(), String.t(), String.t()) ::
    Response.t()
  def create!(%Conn{} = conn, application_id, body, signature, kid, nonce, timestamp) do
    case create(conn, application_id, body, signature, kid, nonce, timestamp) do
      {:ok, response} -> response
      {:error, response} -> raise ExNylasError, response
    end
  end

  @doc"""
  List API keys for an application.

  ## Examples

      iex> {:ok, result} = ExNylas.APIKeys.list(conn, "application_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec list(Conn.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    {:ok, Response.t()} | {:error, Response.t()}
  def list(%Conn{} = conn, application_id, signature, kid, nonce, timestamp) do
    Req.new(
      url: "#{conn.api_server}/v3/admin/applications/#{application_id}/api-keys",
      headers: build_headers(signature, kid, nonce, timestamp)
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> API.handle_response(APIKey)
  end

  @doc"""
  List API keys for an application.

  ## Examples

      iex> result = ExNylas.APIKeys.list!(conn, "application_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec list!(Conn.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    Response.t()
  def list!(%Conn{} = conn, application_id, signature, kid, nonce, timestamp) do
    case list(conn, application_id, signature, kid, nonce, timestamp) do
      {:ok, response} -> response
      {:error, response} -> raise ExNylasError, response
    end
  end

  @doc"""
  Find an API key for an application.

  ## Examples

      iex> {:ok, result} = ExNylas.APIKeys.find(conn, "application_id", "api_key_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec find(Conn.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    {:ok, Response.t()} | {:error, Response.t()}
  def find(%Conn{} = conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
    Req.new(
      url: "#{conn.api_server}/v3/admin/applications/#{application_id}/api-keys/#{api_key_id}",
      headers: build_headers(signature, kid, nonce, timestamp)
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> API.handle_response(APIKey)
  end

  @doc"""
  Find an API key for an application.

  ## Examples

      iex> result = ExNylas.APIKeys.find!(conn, "application_id", "api_key_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec find!(Conn.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    Response.t()
  def find!(%Conn{} = conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
    case find(conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
      {:ok, response} -> response
      {:error, response} -> raise ExNylasError, response
    end
  end

  @doc"""
  Delete an API key for an application.

  ## Examples

      iex> {:ok, result} = ExNylas.APIKeys.delete(conn, "application_id", "api_key_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec delete(Conn.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    {:ok, Response.t()} | {:error, Response.t()}
  def delete(%Conn{} = conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
    Req.new(
      url: "#{conn.api_server}/v3/admin/applications/#{application_id}/api-keys/#{api_key_id}",
      headers: build_headers(signature, kid, nonce, timestamp)
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.delete(conn.options)
    |> API.handle_response(APIKey)
  end

  @doc"""
  Delete an API key for an application.

  ## Examples

      iex> result = ExNylas.APIKeys.delete!(conn, "application_id", "api_key_id", "signature", "kid", "nonce", "timestamp")
  """
  @spec delete!(Conn.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
    Response.t()
  def delete!(%Conn{} = conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
    case delete(conn, application_id, api_key_id, signature, kid, nonce, timestamp) do
      {:ok, response} -> response
      {:error, response} -> raise ExNylasError, response
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
