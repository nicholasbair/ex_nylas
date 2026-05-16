defmodule ExNylas.Error do
  @moduledoc """
  Generic exception for unexpected error conditions.

  Wraps errors that don't fit into specific error types (TransportError,
  DecodeError, etc.) to maintain type safety while handling edge cases.
  """

  @type t :: %__MODULE__{
          message: String.t(),
          reason: atom(),
          original: term()
        }

  defexception [:message, :reason, :original]

  @impl true
  def exception(value) when is_struct(value) do
    %__MODULE__{
      message: "Unexpected error struct: #{inspect(value.__struct__)}",
      reason: :unexpected_struct,
      original: value
    }
  end

  @impl true
  def exception(value) when is_binary(value) do
    %__MODULE__{
      message: "Unexpected error: #{value}",
      reason: :unexpected_error,
      original: value
    }
  end

  @impl true
  def exception(value) do
    %__MODULE__{
      message: "Unexpected error: #{inspect(value)}",
      reason: :unexpected_error,
      original: value
    }
  end

  @impl true
  def message(%__MODULE__{message: message}), do: message || "Unexpected error"
end
