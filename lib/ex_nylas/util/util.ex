defmodule ExNylas.Util do
  @moduledoc """
  Utility functions for ExNylas
  """

  @spec indifferent_put_new(map() | Keyword.t(), any(), any()) :: map() | Keyword.t()
  def indifferent_put_new(map, key, value) when is_map(map) do
    Map.put_new(map, key, value)
  end

  def indifferent_put_new(keyword, key, value) when is_list(keyword) do
    Keyword.put_new(keyword, key, value)
  end

  @spec indifferent_get(map() | Keyword.t(), any(), any()) :: any()
  def indifferent_get(map, key, default \\ nil)
  def indifferent_get(map, key, default) when is_map(map) do
    Map.get(map, key, default)
  end

  def indifferent_get(keyword, key, default) when is_list(keyword) do
    Keyword.get(keyword, key, default)
  end
end