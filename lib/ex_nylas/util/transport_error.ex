defmodule ExNylas.TransportError do
  @moduledoc """
  Exception raised when a network-level failure occurs before receiving an API response.

  This exception represents transport-layer errors such as timeouts, connection
  refusals, DNS resolution failures, and other network issues that prevent a
  successful HTTP request/response cycle.

  ## Fields

    * `message` - Human-readable error message
    * `reason` - Reason atom (`:timeout`, `:econnrefused`, `:nxdomain`, etc.)

  ## Example

      try do
        ExNylas.Grants.me!(conn)
      rescue
        e in ExNylas.TransportError ->
          IO.inspect(e.reason)  # :timeout
          # Handle network failure
      end
  """

  @type t :: %__MODULE__{
          message: String.t(),
          reason: atom()
        }

  defexception [:message, :reason]

  @impl true
  def exception(reason) when is_atom(reason) do
    msg = "Transport failed: #{format_reason(reason)}"

    %ExNylas.TransportError{
      message: msg,
      reason: reason
    }
  end

  defp format_reason(:timeout), do: "request timed out"
  defp format_reason(:econnrefused), do: "connection refused"
  defp format_reason(:nxdomain), do: "domain name not found"
  defp format_reason(:closed), do: "connection closed"
  defp format_reason(:enetunreach), do: "network unreachable"
  defp format_reason(:ehostunreach), do: "host unreachable"
  defp format_reason(:econnreset), do: "connection reset"
  defp format_reason(:epipe), do: "broken pipe"
  defp format_reason(reason), do: inspect(reason)
end
