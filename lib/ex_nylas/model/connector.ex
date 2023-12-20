defmodule ExNylas.Model.Connector do
  @moduledoc """
  A struct representing a Nylas connector.
  """

  use TypedStruct

  typedstruct do
    field(:name, String.t())
    field(:provider, String.t())
    field(:settings, map())
    field(:scope, [String.t()])
  end

  typedstruct module: Build do
    field(:name, String.t())
    field(:provider, String.t())
    field(:settings, map())
    field(:scope, [String.t()])
  end

  def as_struct, do: struct(__MODULE__)

  def as_list, do: [as_struct()]
end
