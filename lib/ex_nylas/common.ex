defmodule ExNylas.Common do
  @moduledoc """
  Common functions for interface modules.
  """

  # Payload format is specific to drafts/messages so encoding is handled here instead of in ExNylas.API
  def build_multipart_body(obj, [] = _attachments) do
    {:multipart, [{"message", Poison.encode!(obj)}]}
  end

  def build_multipart_body(obj, attachments) do
    files = Enum.map(attachments, fn file ->
      basename = Path.basename(file)
      {:file, basename, {"form-data", [{:name, "file"}, {:filename, Path.basename(basename)}]}, []}
    end)

    {:multipart, [{"message", Poison.encode!(obj)}] ++ files}
  end
end
