defmodule ExNylas.Transform do
  @moduledoc """
  Generic transform functions for data returned by the Nylas API
  """

  def transform(object_or_objects, struct, true = _decode?) do
    Poison.decode(object_or_objects, %{as: struct})
  end

  def transform(object_or_objects, _struct, false = _decode?), do: object_or_objects
end
