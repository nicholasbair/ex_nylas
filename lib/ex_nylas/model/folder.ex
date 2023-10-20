defmodule ExNylas.Model.Folder do
  @moduledoc """
  A struct representing a folder.
  """

  use TypedStruct

  typedstruct do
    field(:id, String.t(), enforce: true)
    field(:name, String.t(), enforce: true)
    field(:grant_id, String.t(), enforce: true)
    field(:system_folder, boolean)
    field(:total_count, integer)
    field(:unread_count, integer)
    field(:child_count, integer)
    field(:parent_id, String.t())
  end

  def as_struct(), do: struct(__MODULE__)

  def as_list(), do: [as_struct()]

  typedstruct module: Build do
    field(:name, String.t(), enforce: true)
  end
end
