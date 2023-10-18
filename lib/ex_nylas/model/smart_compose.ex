defmodule ExNylas.Model.SmartCompose do
  @moduledoc """
  A struct for Nylas smart compose.
  """

  use TypedStruct

  typedstruct do
    field(:suggestion, String.t())
  end

  typedstruct module: Build do
    field(:prompt, String.t())
  end
end
