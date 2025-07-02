defmodule ExNylas.Multipart do
  @moduledoc false

  @spec build_multipart(map(), [String.t() | tuple()]) :: {Enum.t(), String.t(), integer()}
  def build_multipart(obj, attachments) do
    multipart =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field(Jason.encode!(obj), :message))
      |> add_attachments(attachments)

    {
      Multipart.body_stream(multipart),
      Multipart.content_type(multipart, "multipart/form-data"),
      Multipart.content_length(multipart)
    }
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
    Enum.reduce(attachments, multipart, fn f, multipart ->
      multipart
      |> Multipart.add_part(build_file(f))
    end)
  end

  defp build_file({cid, file_path}) do
    {filename, file_contents} = get_file_data(file_path)

    Multipart.Part.file_content_field(filename, file_contents, cid, filename: filename)
  end

  defp build_file(file_path) do
    {filename, file_contents} = get_file_data(file_path)

    Multipart.Part.file_content_field(filename, file_contents, :file, filename: filename)
  end

  defp get_file_data(file_path) do
    filename = Path.basename(file_path)
    {:ok, file_contents} = File.read(file_path)

    {filename, file_contents}
  end
end
