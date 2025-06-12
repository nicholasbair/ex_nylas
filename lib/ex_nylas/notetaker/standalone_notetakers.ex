defmodule ExNylas.StandaloneNotetakers do
  @moduledoc """
  Interface for Standalone Notetakers (Notetakers not associated with a grant).
  """

  alias ExNylas.Connection, as: Conn
  alias ExNylas.{
    API,
    Notetaker,
    Notetaker.Media,
    Response
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
  @spec cancel(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def cancel(%Conn{} = conn, id) do
    Req.new(
      url: "#{conn.api_server}/v3/notetakers/#{id}/cancel",
      auth: API.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.delete(conn.options)
    |> API.handle_response(Notetaker)
  end

  @doc """
  Cancel a scheduled notetaker.

  ## Examples

      iex> response = ExNylas.StandaloneNotetakers.cancel!(conn, id)
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

      iex> {:ok, response} = ExNylas.StandaloneNotetakers.leave(conn, id)
  """
  @spec leave(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def leave(%Conn{} = conn, id) do
    Req.new(
      url: "#{conn.api_server}/v3/notetakers/#{id}/leave",
      auth: API.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.post(conn.options)
    |> API.handle_response(Notetaker)
  end

  @doc """
  Remove a notetaker from a meeting.

  ## Examples

      iex> response = ExNylas.StandaloneNotetakers.leave!(conn, id)
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

      iex> {:ok, response} = ExNylas.StandaloneNotetakers.media(conn, id)
  """
  @spec media(Conn.t(), String.t()) :: {:ok, Response.t()} | {:error, Response.t()}
  def media(%Conn{} = conn, id) do
    Req.new(
      url: "#{conn.api_server}/v3/notetakers/#{id}/media",
      auth: API.auth_bearer(conn),
      headers: API.base_headers()
    )
    |> API.maybe_attach_telemetry(conn)
    |> Req.get(conn.options)
    |> API.handle_response(Media)
  end

  @doc """
  Get media for a notetaker.

  ## Examples

      iex> response = ExNylas.StandaloneNotetakers.media!(conn, id)
  """
  @spec media!(Conn.t(), String.t()) :: Response.t()
  def media!(%Conn{} = conn, id) do
    case media(conn, id) do
      {:ok, response} -> response
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
