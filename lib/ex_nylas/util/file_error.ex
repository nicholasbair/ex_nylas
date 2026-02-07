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

  @impl true
  def exception(message) when is_binary(message) do
    %ExNylas.FileError{
      message: message,
      path: nil,
      reason: :unknown
    }
  end

  @impl true
  def exception(keywords) when is_list(keywords) do
    keywords
    |> Enum.into(%{})
    |> exception()
  end

  @impl true
  def exception(%__MODULE__{} = error) do
    if error.message do
      error
    else
      msg = if error.path do
        "Failed to read file at #{error.path}: #{format_reason(error.reason)}"
      else
        "File operation failed: #{format_reason(error.reason)}"
      end
      %{error | message: msg}
    end
  end

  @impl true
  def exception(value) when is_map(value) and not is_struct(value) do
    path = Map.get(value, :path) || Map.get(value, "path")
    reason = Map.get(value, :reason) || Map.get(value, "reason") || :unknown
    message = Map.get(value, :message) || Map.get(value, "message")

    msg = message || if path do
      "Failed to read file at #{path}: #{format_reason(reason)}"
    else
      "File operation failed: #{format_reason(reason)}"
    end

    %ExNylas.FileError{
      message: msg,
      path: path,
      reason: reason
    }
  end

  @impl true
  def message(%__MODULE__{message: message}) do
    message || "File operation failed"
  end

  defp format_reason(:enoent), do: "file does not exist"
  defp format_reason(:eacces), do: "permission denied"
  defp format_reason(:eisdir), do: "is a directory"
  defp format_reason(:enotdir), do: "not a directory"
  defp format_reason(:enomem), do: "not enough memory"
  defp format_reason(:enospc), do: "no space left on device"
  defp format_reason(reason), do: inspect(reason)
end
