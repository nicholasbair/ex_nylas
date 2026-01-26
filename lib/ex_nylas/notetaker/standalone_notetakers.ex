defmodule ExNylas.StandaloneNotetakers do
  @moduledoc """
  Interface for Standalone Notetakers (Notetakers not associated with a grant).

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/standalone-notetaker)
  """

  alias ExNylas.{
    API,
    Auth,
    Connection,
    Notetaker,
    Notetaker.Media,
    Response,
    ResponseHandler,
    Telemetry
  }

  use ExNylas,
    object: "notetakers",
    struct: Notetaker,
    readable_name: "notetaker",
    include: [:list, :first, :find, :create, :update, :all, :build],
    use_admin_url: true

  @doc """
  Cancel a scheduled notetaker.

  ## Examples

      iex> {:ok, response} = ExNylas.StandaloneNotetakers.cancel(conn, id)
  """
  @spec cancel(Connection.t(), String.t()) ::
          {:ok, Response.t()}
          | {:error,
               ExNylas.APIError.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()}
  def cancel(%Connection{} = conn, id) do
    Req.new(
      url: "#{conn.api_server}/v3/notetakers/#{id}/cancel",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.delete(conn.options)
    |> ResponseHandler.handle_response(Notetaker)
  end

  @doc """
  Cancel a scheduled notetaker.

  ## Examples

      iex> response = ExNylas.StandaloneNotetakers.cancel!(conn, id)
  """
  @spec cancel!(Connection.t(), String.t()) :: Response.t()
  def cancel!(%Connection{} = conn, id) do
    case cancel(conn, id) do
      {:ok, response} -> response
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Remove a notetaker from a meeting.

  ## Examples

      iex> {:ok, response} = ExNylas.StandaloneNotetakers.leave(conn, id)
  """
  @spec leave(Connection.t(), String.t()) ::
          {:ok, Response.t()}
          | {:error,
               ExNylas.APIError.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()}
  def leave(%Connection{} = conn, id) do
    Req.new(
      url: "#{conn.api_server}/v3/notetakers/#{id}/leave",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> ResponseHandler.handle_response(Notetaker)
  end

  @doc """
  Remove a notetaker from a meeting.

  ## Examples

      iex> response = ExNylas.StandaloneNotetakers.leave!(conn, id)
  """
  @spec leave!(Connection.t(), String.t()) :: Response.t()
  def leave!(%Connection{} = conn, id) do
    case leave(conn, id) do
      {:ok, response} -> response
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Get media for a notetaker.

  ## Examples

      iex> {:ok, response} = ExNylas.StandaloneNotetakers.media(conn, id)
  """
  @spec media(Connection.t(), String.t()) ::
          {:ok, Response.t()}
          | {:error,
               ExNylas.APIError.t()
               | ExNylas.TransportError.t()
               | ExNylas.DecodeError.t()}
  def media(%Connection{} = conn, id) do
    Req.new(
      url: "#{conn.api_server}/v3/notetakers/#{id}/media",
      auth: Auth.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> Telemetry.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> ResponseHandler.handle_response(Media)
  end

  @doc """
  Get media for a notetaker.

  ## Examples

      iex> response = ExNylas.StandaloneNotetakers.media!(conn, id)
  """
  @spec media!(Connection.t(), String.t()) :: Response.t()
  def media!(%Connection{} = conn, id) do
    case media(conn, id) do
      {:ok, response} -> response
      {:error, exception} -> raise exception
    end
  end
end
