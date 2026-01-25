defmodule ExNylas.APIError do
  @moduledoc """
  Exception raised when an API request fails with a non-2xx HTTP response.

  This exception contains structured error information from the Nylas API,
  including the full response, status atom, and request ID for debugging.

  ## Fields

    * `message` - Human-readable error message
    * `response` - Full `ExNylas.Response.t()` struct with error details
    * `status` - Status atom (`:not_found`, `:bad_request`, etc.)
    * `request_id` - Nylas request ID for debugging (may be nil)

  ## Example

      try do
        ExNylas.Grants.me!(conn)
      rescue
        e in ExNylas.APIError ->
          IO.inspect(e.status)       # :not_found
          IO.inspect(e.request_id)   # "abc123..."
      end
  """

  alias ExNylas.Response

  @type t :: %__MODULE__{
          message: String.t(),
          response: Response.t(),
          status: atom(),
          request_id: String.t() | nil
        }

  defexception [:message, :response, :status, :request_id]

  @impl true
  def exception(%Response{} = response) do
    error_message = extract_error_message(response)
    request_id = response.request_id

    msg = build_message(response.status, error_message, request_id)

    %ExNylas.APIError{
      message: msg,
      response: response,
      status: response.status,
      request_id: request_id
    }
  end

  defp extract_error_message(%Response{error: nil}), do: "API request failed"

  defp extract_error_message(%Response{error: %{message: msg}}) when is_binary(msg),
    do: msg

  defp extract_error_message(%Response{error: error}) when is_map(error),
    do: "API request failed"

  defp extract_error_message(_), do: "API request failed"

  defp build_message(status_atom, error_msg, request_id) do
    base = "API request failed with status #{status_atom}: #{error_msg}"

    if request_id do
      "#{base} [request_id: #{request_id}]"
    else
      base
    end
  end
end
