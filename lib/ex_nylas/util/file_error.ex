defmodule ExNylas.FileError do
  @moduledoc """
  Exception raised when file operations fail.

  This includes errors from reading files for attachments or other file-based operations.
  """

  @type t :: %__MODULE__{message: String.t(), path: String.t(), reason: atom()}

  defexception [:message, :path, :reason]

  @impl true
  def exception({path, reason}) when is_binary(path) do
    msg = "Failed to read file at #{path}: #{format_reason(reason)}"

    %ExNylas.FileError{
      message: msg,
      path: path,
      reason: reason
    }
  end

  defp format_reason(:enoent), do: "file does not exist"
  defp format_reason(:eacces), do: "permission denied"
  defp format_reason(:eisdir), do: "is a directory"
  defp format_reason(:enotdir), do: "not a directory"
  defp format_reason(:enomem), do: "not enough memory"
  defp format_reason(:enospc), do: "no space left on device"
  defp format_reason(reason), do: inspect(reason)
end
