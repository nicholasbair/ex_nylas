defmodule ExNylas.Model.Provider do
  @moduledoc """
  Structs for Nylas providers.
  """

  use TypedStruct

  typedstruct do
    field(:provider, String.t())
    field(:type, String.t())
    field(:email_address, String.t())
    field(:detected, boolean())
  end
end
