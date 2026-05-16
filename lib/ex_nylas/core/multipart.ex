defmodule ExNylas.Multipart do
  @moduledoc false

  alias ExNylas.Multipart.Attachment

  @spec build_multipart(map(), [Attachment.t() | String.t() | tuple()]) ::
          {:ok, {Enum.t(), String.t(), integer()}} | {:error, ExNylas.FileError.t()}
  def build_multipart(obj, attachments) do
    base_multipart =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field(Jason.encode!(obj), :message))

    case add_attachments(base_multipart, attachments) do
      {:ok, multipart} ->
        {:ok,
         {
           Multipart.body_stream(multipart),
           Multipart.content_type(multipart, "multipart/form-data"),
           Multipart.content_length(multipart)
         }}

      {:error, _} = error ->
        error
    end
  end

  @spec build_raw_multipart(String.t()) :: {Enum.t(), String.t(), integer()}
  def build_raw_multipart(mime) do
    multipart =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field(mime, :mime))

    {
      Multipart.body_stream(multipart),
      Multipart.content_type(multipart, "multipart/form-data"),
      Multipart.content_length(multipart)
    }
  end

  defp add_attachments(multipart, attachments) do
    Enum.reduce_while(attachments, {:ok, multipart}, fn f, {:ok, acc} ->
      case build_file(f) do
        {:ok, part} ->
          {:cont, {:ok, Multipart.add_part(acc, part)}}

        {:error, _} = error ->
          {:halt, error}
      end
    end)
  end

  defp build_file(%Attachment{content: content, filename: filename, content_id: cid})
       when is_binary(content) do
    name = cid || :file
    {:ok, Multipart.Part.file_content_field(filename, content, name)}
  end

  defp build_file(%Attachment{content: content, filename: filename, size: size, content_id: cid}) do
    name = cid || :file
    headers = build_headers(filename, name)
    body = ensure_stream(content)
    {:ok, %Multipart.Part{body: body, content_length: size, headers: headers}}
  end

  defp build_file({cid, file_path}) do
    case get_file_data(file_path) do
      {:ok, {filename, file_contents}} ->
        {:ok, Multipart.Part.file_content_field(filename, file_contents, cid, filename: filename)}

      {:error, _} = error ->
        error
    end
  end

  defp build_file(file_path) when is_binary(file_path) do
    case get_file_data(file_path) do
      {:ok, {filename, file_contents}} ->
        {:ok, Multipart.Part.file_content_field(filename, file_contents, :file, filename: filename)}

      {:error, _} = error ->
        error
    end
  end

  defp ensure_stream(%Stream{} = stream), do: stream
  defp ensure_stream(%File.Stream{} = stream), do: stream
  defp ensure_stream(enum), do: Stream.map(enum, & &1)

  defp build_headers(filename, name) do
    content_type = MIME.from_path(filename)
    disposition = "form-data; name=\"#{name}\"; filename=\"#{filename}\""

    [
      {"content-type", content_type},
      {"content-disposition", disposition}
    ]
  end

  defp get_file_data(file_path) do
    filename = Path.basename(file_path)

    case File.read(file_path) do
      {:ok, file_contents} ->
        {:ok, {filename, file_contents}}

      {:error, reason} ->
        {:error, ExNylas.FileError.exception({file_path, reason})}
    end
  end
end
