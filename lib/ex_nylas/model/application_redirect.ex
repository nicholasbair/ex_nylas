defmodule ExNylas.Model.ApplicationRedirect do
  @moduledoc """
  A struct for Nylas application redirect.
  """

  use TypedStruct

  typedstruct do
    field(:id, String.t())
    field(:url, String.t())
    field(:platform, String.t())
  end

  def as_struct, do: struct(__MODULE__)
  def as_list, do: [as_struct()]

  typedstruct module: Build do
    field(:url, String.t())
    field(:platform, String.t())
  end
end
