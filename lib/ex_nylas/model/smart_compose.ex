defmodule ExNylas.Model.SmartCompose do
  @moduledoc """
  A struct for Nylas smart compose.
  """

  use TypedStruct

  typedstruct do
    field(:suggestion, String.t())
  end

  def as_struct(), do: struct(__MODULE__)
end
