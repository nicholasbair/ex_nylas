defmodule ExNylas.Transform do
  @moduledoc """
  Generic transform functions for data returned by the Nylas API
  """

  def transform(nil), do: nil

  def transform(object_or_objects, struct) do
    Poison.decode(object_or_objects, %{as: struct})
  end
end
