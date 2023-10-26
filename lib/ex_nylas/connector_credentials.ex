defmodule ExNylas.ConnectorCredentials do
  @moduledoc """
  Interface for Nylas connector credentials.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Model.ConnectorCredential, as: Cred

  @doc """
  List connector credentials.

  Example
      {:ok, creds} = conn |> ExNylas.ConnectorCredentials.list()
  """
  def list(%Conn{} = conn, provider, params \\ %{}) do
    API.get(
      "#{conn.api_server}/connectors/#{provider}/creds",
      API.header_api_key(conn),
      [
        timeout: conn.timeout,
        recv_timeout: conn.recv_timeout,
        params: params
      ]
    )
    |> API.handle_response(Cred.as_list())
  end

  @doc """
  List connector credentials.

  Example
      creds = conn |> ExNylas.ConnectorCredentials.list!()
  """
  def list!(%Conn{} = conn, provider, params \\ %{}) do
    case list(conn, provider, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Create a connector credential.

  Example
      {:ok, cred} = conn |> ExNylas.ConnectorCredentials.create(`provider`, `body`)
  """
  def create(%Conn{} = conn, provider, body) do
    API.post(
      "#{conn.api_server}/connectors/#{provider}/creds",
      body,
      API.header_api_key(conn),
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(Cred.as_struct())
  end

  @doc """
  Create a connector credential.

  Example
      cred = conn |> ExNylas.ConnectorCredentials.create!(`provider`, `body`)
  """
  def create!(%Conn{} = conn, provider, body) do
    case create(conn, provider, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Find a connector credential.

  Example
      {:ok, cred} = conn |> ExNylas.ConnectorCredentials.find(`provider`, `id`)
  """
  def find(%Conn{} = conn, provider, id) do
    API.get(
      "#{conn.api_server}/connectors/#{provider}/creds/#{id}",
      API.header_api_key(conn),
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(Cred.as_struct())
  end

  @doc """
  Find a connector credential.

  Example
      cred = conn |> ExNylas.ConnectorCredentials.find(`provider`, `id`)
  """
  def find!(%Conn{} = conn, provider, id) do
    case find(conn, provider, id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Delete a connector credential.

  Example
      {:ok, res} = conn |> ExNylas.ConnectorCredentials.delete(`provider`, `id`)
  """
  def delete(%Conn{} = conn, provider, id) do
    API.delete(
      "#{conn.api_server}/connectors/#{provider}/creds/#{id}",
      API.header_api_key(conn),
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response()
  end

  @doc """
  Delete a connector credential.

  Example
      res = conn |> ExNylas.ConnectorCredentials.delete!(`provider`, `id`)
  """
  def delete!(%Conn{} = conn, provider, id) do
    case delete(conn, provider, id) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Update a connector credential.

  Example
      {:ok, cred} = conn |> ExNylas.ConnectorCredentials.update(`provider`, `id`, `changeset`)
  """
  def update(%Conn{} = conn, provider, id, changeset) do
    API.patch(
      "#{conn.api_server}/connectors/#{provider}/creds/#{id}",
      changeset,
      API.header_api_key(conn),
      [timeout: conn.timeout, recv_timeout: conn.recv_timeout]
    )
    |> API.handle_response(Cred.as_struct())
  end

  @doc """
  Update a connector credential.

  Example
      cred = conn |> ExNylas.ConnectorCredentials.update!(`provider`, `id`, `changeset`)
  """
  def update!(%Conn{} = conn, provider, id, changeset) do
    case update(conn, provider, id, changeset) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
