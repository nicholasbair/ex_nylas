defmodule ExNylas.DecodeError do
  @moduledoc """
  Exception raised when response decoding fails.

  This exception is raised when the SDK cannot parse or decode a response,
  such as invalid JSON, unexpected response format, or other decoding issues.

  ## Fields

    * `message` - Human-readable error message
    * `reason` - The underlying error reason
    * `response` - The raw response that failed to decode (optional)

  ## Example

      try do
        ExNylas.Grants.me!(conn)
      rescue
        error in ExNylas.DecodeError ->
          IO.puts("Failed to decode response: \#{error.message}")
          IO.inspect(error.reason)
      end
  """

  @type t :: %__MODULE__{
          message: String.t(),
          reason: term(),
          response: term()
        }

  defexception [:message, :reason, :response]

  @impl true
  def exception({reason, response}) do
    msg = "Failed to decode response: #{inspect(reason)}"

    %ExNylas.DecodeError{
      message: msg,
      reason: reason,
      response: response
    }
  end

  @impl true
  def exception(reason) do
    msg = "Failed to decode response: #{inspect(reason)}"

    %ExNylas.DecodeError{
      message: msg,
      reason: reason,
      response: nil
    }
  end
end
