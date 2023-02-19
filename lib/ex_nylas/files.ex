defmodule ExNylas.File do
  @moduledoc """
  A struct representing a file.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A file"
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
    field(:content_type, String.t())
    field(:size, non_neg_integer())
    field(:filename, String.t())
    field(:message_ids, list())
    field(:content_id, String.t())
    field(:content_disposition, String.t())
  end
end

defmodule ExNylas.Files do
  @moduledoc """
  Interface for Nylas file.
  """

  use ExNylas,
    object: "files",
    struct: ExNylas.File,
    include: [:list, :first, :find, :delete, :create, :all]

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Download a file.

  Example
      {:ok, binary} = conn |> ExNylas.Files.download(`id`)
  """
  def download(%Conn{} = conn, id) do
    API.get(
      "#{conn.api_server}/files/#{id}/download",
      API.header_bearer(conn)
    )
    |> API.handle_response(ExNylas.File)
  end

  @doc """
  Download a file.

  Example
      binary = conn |> ExNylas.Files.download!(`id`)
  """
  def download!(%Conn{} = conn, id) do
    case download(conn, id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Upload a file.

  Example
      {:ok, result} = conn |> ExNylas.Files.upload(`path_to_file`)
  """
  def upload(%Conn{} = conn, path_to_file) do
    API.post(
      "#{conn.api_server}/files",
      API.header_bearer(conn),
      {:multipart, [{:file, path_to_file}]}
    )
    |> API.handle_response(ExNylas.File)
  end

  @doc """
  Upload a file.

  Example
      result = conn |> ExNylas.Files.upload!(`path_to_file`)
  """
  def upload!(%Conn{} = conn, path_to_file) do
    case upload(conn, path_to_file) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
