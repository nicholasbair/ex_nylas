defmodule ExNylas.Model.ContactGroup do
  @moduledoc """
  A struct representing a contact group.
  """

  use TypedStruct

  typedstruct do
    field(:grant_id, String.t())
    field(:group_type, String.t())
    field(:id, String.t())
    field(:name, String.t())
    field(:object, String.t())
    field(:path, String.t())
  end

  def as_struct(), do: struct(__MODULE__)

  def as_list(), do: [as_struct()]
end
