defmodule ExNylasError do
  @moduledoc """
  Standard error wrapper
  """

  defexception [:message]

  @impl true
  def exception(value) do
    msg = "Error: #{inspect(value)}"
    %ExNylasError{message: msg}
  end
end
