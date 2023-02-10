defmodule ExNylas.Transform do
  @moduledoc """
  Generic transform functions for data returned by the Nylas API
  """

  def transform({:ok, nil}), do: {:ok, nil}

  def transform({:ok, object_or_objects}, struct),
    do: {:ok, transform(object_or_objects, struct)}

  def transform(objects, struct) when is_list(objects),
    do: Enum.map(objects, fn m -> transform(m, struct) end)

  def transform(object, struct) do
    val =
      object
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put(acc, String.to_atom(k), v)
      end)

    struct(struct, val)
  end
end
