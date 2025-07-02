defmodule ExNylas.Notetakers do
  @moduledoc """
  Interface for Notetaker.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/notetaker)
  """

  alias ExNylas.Connection, as: Conn
  alias ExNylas.{
    API, Auth, ResponseHandler, Telemetry,
    Notetaker,
    Notetaker.Media,
    Response
  }

  use ExNylas,
    object: "notetakers",
    struct: Notetaker,
    readable_name: "notetaker",
    include: [:list, :first, :find, :create, :update, :all, :build]

  @doc """
  Cancel a scheduled notetaker.

  ## Examples

      iex> {:ok, response} = ExNylas.Notetakers.cancel(conn, id)
  """
  @spec cancel(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def cancel(%Conn{} = conn, id) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/notetakers/#{id}/cancel",
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

      iex> response = ExNylas.Notetakers.cancel!(conn, id)
  """
  @spec cancel!(Conn.t(), String.t()) :: Response.t()
  def cancel!(%Conn{} = conn, id) do
    case cancel(conn, id) do
      {:ok, response} -> response
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Remove a notetaker from a meeting.

  ## Examples

      iex> {:ok, response} = ExNylas.Notetakers.leave(conn, id)
  """
  @spec leave(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def leave(%Conn{} = conn, id) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/notetakers/#{id}/leave",
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

      iex> response = ExNylas.Notetakers.leave!(conn, id)
  """
  @spec leave!(Conn.t(), String.t()) :: Response.t()
  def leave!(%Conn{} = conn, id) do
    case leave(conn, id) do
      {:ok, response} -> response
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Get media for a notetaker.

  ## Examples

      iex> {:ok, response} = ExNylas.Notetakers.media(conn, id)
  """
  @spec media(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def media(%Conn{} = conn, id) do
    Req.new(
      url: "#{conn.api_server}/v3/grants/#{conn.grant_id}/notetakers/#{id}/media",
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

      iex> response = ExNylas.Notetakers.media!(conn, id)
  """
  @spec media!(Conn.t(), String.t()) :: Response.t()
  def media!(%Conn{} = conn, id) do
    case media(conn, id) do
      {:ok, response} -> response
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
