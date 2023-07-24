defmodule ExNylas.File do
  @moduledoc """
  A struct representing a file.
  """

  defstruct [
    :id,
    :grant_id,
    :content_type,
    :size,
    :filename,
    :is_inline,
    :content_disposition,
  ]

  @typedoc "A file"
  @type t :: %__MODULE__{
    id: String.t(),
    grant_id: String.t(),
    content_type: String.t(),
    size: non_neg_integer(),
    filename: String.t(),
    is_inline: boolean(),
    content_disposition: String.t(),
  }

  def as_struct, do: %ExNylas.File{}

  def as_list, do: [as_struct()]
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
    |> API.handle_response()
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
