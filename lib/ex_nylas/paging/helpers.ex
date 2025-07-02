defmodule ExNylas.Paging.Helpers do
  @moduledoc false

  @spec maybe_delay(integer()) :: :ok
  def maybe_delay(delay) when delay <= 0, do: :ok
  def maybe_delay(delay) when delay > 0, do: :timer.sleep(delay)

  @spec send_or_accumulate((any() -> any()) | nil, any() | nil, [any()], [any()]) :: [any()]
  def send_or_accumulate(nil, _, acc, data), do: acc ++ data

  def send_or_accumulate(send_to, nil, acc, data) do
    send_to.(data)
    acc
  end

  def send_or_accumulate(send_to, with_metadata, acc, data) do
    send_to.({with_metadata, data})
    acc
  end
end
