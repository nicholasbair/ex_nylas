defmodule ExNylas.Multipart.Attachment do
  @moduledoc """
  Struct representing a file attachment for multipart requests.

  This is the canonical way to pass attachments to `ExNylas.Messages.send/3`,
  `ExNylas.Drafts.create/3`, and `ExNylas.Drafts.update/4`.

  The `content` field accepts either a binary (already in memory) or any
  enumerable/stream (e.g. an S3 download stream) for streaming uploads
  without loading the entire file into memory.

  The `size` field is required so the multipart content-length can be
  computed.  For S3 objects this is typically available from object metadata.

  ## Examples

      # Binary content
      %ExNylas.Multipart.Attachment{
        filename: "report.pdf",
        content: binary_data,
        size: byte_size(binary_data)
      }

      # Stream content (e.g. from S3)
      %ExNylas.Multipart.Attachment{
        filename: "report.pdf",
        content: s3_stream,
        size: 102_400
      }

      # Inline image with content_id
      %ExNylas.Multipart.Attachment{
        filename: "logo.png",
        content: image_data,
        size: byte_size(image_data),
        content_id: "logo-cid"
      }

      # From a local file
      {:ok, attachment} = ExNylas.Multipart.Attachment.from_file("/path/to/file.pdf")
  """

  @type t :: %__MODULE__{
          filename: String.t(),
          content: binary() | Enum.t(),
          size: non_neg_integer(),
          content_id: String.t() | nil
        }

  defstruct [:filename, :content, :size, :content_id]

  @doc """
  Build an attachment from a local file path.

  Reads the file into memory and returns an `%Attachment{}` struct.

  ## Examples

      {:ok, attachment} = ExNylas.Multipart.Attachment.from_file("/path/to/file.pdf")
  """
  @spec from_file(String.t()) :: {:ok, t()} | {:error, ExNylas.FileError.t()}
  def from_file(path) do
    from_file(path, nil)
  end

  @doc """
  Build an attachment from a local file path with a content-id for inline images.

  ## Examples

      {:ok, attachment} = ExNylas.Multipart.Attachment.from_file("/path/to/image.png", "cid123")
  """
  @spec from_file(String.t(), String.t() | nil) :: {:ok, t()} | {:error, ExNylas.FileError.t()}
  def from_file(path, content_id) do
    case File.read(path) do
      {:ok, content} ->
        {:ok,
         %__MODULE__{
           filename: Path.basename(path),
           content: content,
           size: byte_size(content),
           content_id: content_id
         }}

      {:error, reason} ->
        {:error, ExNylas.FileError.exception({path, reason})}
    end
  end
end
