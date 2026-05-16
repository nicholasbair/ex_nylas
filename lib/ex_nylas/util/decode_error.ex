defmodule ExNylas.DecodeError do
  @moduledoc """
  Exception raised when response decoding fails.

  This exception is raised when the SDK cannot parse or decode a response,
  such as invalid JSON, unexpected response format, or other decoding issues.
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
  def exception(message) when is_binary(message) do
    %ExNylas.DecodeError{
      message: message,
      reason: :decode_failed,
      response: nil
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
    %{error | message: error.message || "Failed to decode response: #{inspect(error.reason)}"}
  end

  @impl true
  def exception(value) when is_map(value) and not is_struct(value) do
    reason = Map.get(value, :reason) || Map.get(value, "reason") || :decode_failed
    response = Map.get(value, :response) || Map.get(value, "response")
    msg = Map.get(value, :message) || Map.get(value, "message") || "Failed to decode response: #{inspect(reason)}"

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

  @impl true
  def message(%__MODULE__{message: message}) do
    message || "Failed to decode response"
  end
end
