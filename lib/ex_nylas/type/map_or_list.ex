defmodule ExNylas.Type.MapOrList do
  @moduledoc """
  Custom Ecto type for map or list.
  """

  use Ecto.Type

  def type, do: :any

  def cast(data) when is_map(data) or is_list(data), do: {:ok, data}
  def cast(_), do: :error

  def load(data) when is_map(data) or is_list(data), do: {:ok, data}

  def dump(data) when is_map(data) or is_list(data), do: {:ok, data}
end
