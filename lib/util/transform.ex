defmodule ExNylas.Transform do
  @moduledoc """
  Generic transform functions for data returned by the Nylas API
  """

  def transform({:ok, message_or_messages}, struct), do: {:ok, transform(message_or_messages, struct)}
  def transform(messages, struct) when is_list(messages), do: Enum.map(messages, fn m -> transform(m, struct) end)
  def transform(message, struct) do
    val =
      message
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put(acc, String.to_atom(k), v)
      end)

    struct(struct, val)
  end

end
