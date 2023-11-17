defmodule ExNylas.Common do
  @moduledoc """
  Common functions for interface modules.
  """

  # Payload format is specific to drafts/messages so encoding is handled here instead of in ExNylas.API
  def build_multipart_body(obj, [] = _attachments) do
    {:multipart, [{"message", Poison.encode!(obj)}]}
  end

  def build_multipart_body(obj, attachments) do
    {:multipart, [{"message", Poison.encode!(obj)}] ++ Enum.map(attachments, &build_file/1)}
  end

  defp build_file({cid, filepath}) do
    basename = Path.basename(filepath)
    {:file, basename, {"form-data", [{:name, cid}, {:filename, Path.basename(basename)}]}, []}
  end

  defp build_file(filepath) do
    basename = Path.basename(filepath)
    {:file, basename, {"form-data", [{:name, "file"}, {:filename, Path.basename(basename)}]}, []}
  end
end
