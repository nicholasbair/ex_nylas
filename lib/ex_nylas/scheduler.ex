defmodule ExNylas.Scheduler do
  @moduledoc """
  A struct representing a scheduler page config.
  """
  use TypedStruct
  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  use ExNylas,
    struct: __MODULE__,
    include: [:all]

  typedstruct do
    @typedoc "A scheduler page config"
    field(:access_tokens, list)
    field(:config, map())
    field(:booking, map())
    field(:name, String.t())
    field(:slug, String.t())
  end

  @doc """
  Build a scheduler.

  Note - call save/2 to create the page on Nylas.

  Example
      {:ok, scheduler} = conn |> ExNylas.Scheduler.build(`config`)
  """
  def build(scheduler) do
    try do
      res = build!(scheduler)
      {:ok, res}
    rescue
      e in _ -> {:error, e}
    end
  end

  @doc """
  Build a scheduler.

  Note - call save/2 to create the page on Nylas.

  Example
      scheduler = conn |> ExNylas.Scheduler.build(`config`)
  """
  def build!(scheduler), do: struct!(__MODULE__, scheduler)

  @doc """
  Fetch scheduler pages.

  Example
      {:ok, scheduler_pages} = conn |> ExNylas.Scheduler.list()
  """
  def list(%Conn{} = conn, params \\ %{}) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        API.get(
          url <> "/manage/pages",
          API.header_bearer(conn),
          params: params
        )
        |> API.handle_response(__MODULE__)

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Fetch scheduler pages.

  Example
      scheduler_pages = conn |> ExNylas.Scheduler.list()
  """
  def list!(%Conn{} = conn, params \\ %{}) do
    case list(conn, params) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Fetch the first scheduler page.

  Example
      {:ok, scheduler_page} = conn |> ExNylas.Scheduler.first()
  """
  def first(%Conn{} = conn, params \\ %{}) do
    case list(conn, Map.put(params, :limit, 1)) do
      {:ok, res} -> {:ok, Enum.at(res, 0)}
      res -> res
    end
  end

  @doc """
  Fetch the first page.

  Example
      scheduler_page = conn |> ExNylas.Scheduler.first()
  """
  def first!(%Conn{} = conn, params \\ %{}) do
    case first(conn, params) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Fetch a scheduler page by id.

  Example
      {:ok, scheduler_page} = conn |> ExNylas.Scheduler.find(`id`)
  """
  def find(%Conn{} = conn, id) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        API.get(
          url <> "/manage/pages/#{id}",
          API.header_bearer(conn)
        )
        |> API.handle_response(__MODULE__)

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Fetch a scheduler page by id.

  Example
      scheduler_page = conn |> ExNylas.Scheduler.find!(`id`)
  """
  def find!(%Conn{} = conn, id) do
    case find(conn, id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Delete a scheduler page.

  Example
      {:ok, _} = conn |> ExNylas.Scheduler.delete(`id`)
  """
  def delete(%Conn{} = conn, id) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        API.delete(
          url <> "/manage/pages/#{id}",
          API.header_bearer(conn)
        )
        |> API.handle_response()

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Delete a scheduler page.

  Example
      conn |> ExNylas.Scheduler.delete!(`id`)
  """
  def delete!(%Conn{} = conn, id) do
    case delete(conn, id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Create a scheduler page.

  Example
      {:ok, page} = conn |> ExNylas.Scheduler.save(`page_config`)
  """
  def save(%Conn{} = conn, page_config) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        ExNylas.API.post(
          url,
          page_config,
          ExNylas.API.header_bearer(conn) ++ ["content-type": "application/json"]
        )
        |> API.handle_response(__MODULE__)

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Create a scheduler page.

  Example
      result = conn |> ExNylas.Scheduler.save(`page_config`)
  """
  def save!(%Conn{} = conn, page_config) do
    case save(conn, page_config) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Update a scheduler page.

  Example
      {:ok, page} = conn |> ExNylas.Scheduler.update(`page_config`, `id`)
  """
  def update(%Conn{} = conn, page_config, id) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        ExNylas.API.put(
          url <> "/" <> id,
          page_config,
          ExNylas.API.header_bearer(conn) ++ ["content-type": "application/json"]
        )
        |> API.handle_response(__MODULE__)

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Update a scheduler page.

  Example
      result = conn |> ExNylas.Scheduler.update(`page_config`, `id`)
  """
  def update!(%Conn{} = conn, page_config, id) do
    case update(conn, page_config, id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  # -- Private --

  defp convert_to_scheduler_url(%Conn{} = conn) do
    case conn.api_server do
      "https://api.nylas.com" -> {:ok, "https://api.schedule.nylas.com"}
      "https://ireland.api.nylas.com" -> {:ok, "https://ireland.api.schedule.nylas.com"}
      _ -> {:error, "No match found for api_server URI"}
    end
  end
end
