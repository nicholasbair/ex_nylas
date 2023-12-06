defmodule ExNylas.Model.Calendar do
  @moduledoc """
  A struct representing a calendar.
  """

  use TypedStruct

  typedstruct do
    field(:grant_id, String.t())
    field(:description, String.t())
    field(:id, String.t())
    field(:is_primary, boolean())
    field(:location, String.t())
    field(:name, String.t())
    field(:object, String.t())
    field(:read_only, boolean())
    field(:timezone, String.t())
    field(:hex_color, String.t())
    field(:hex_foreground_color, String.t())
    field(:is_owned_by_user, boolean())
    field(:metadata, map())
  end

  def as_struct(), do: struct(__MODULE__)

  def as_list(), do: [as_struct()]

  typedstruct module: Build do
    field(:name, String.t(), enforce: true)
    field(:description, String.t())
    field(:location, String.t())
    field(:timezone, String.t())
  end
end
