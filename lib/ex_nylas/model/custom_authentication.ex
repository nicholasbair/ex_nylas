defmodule ExNylas.Model.CustomAuthentication do
  @moduledoc """
  Structs for Nylas custom authentication.
  """

  use TypedStruct

  typedstruct module: Build do
    field(:provider, String.t())
    field(:settings, map())
    field(:state, String.t())
  end
end
