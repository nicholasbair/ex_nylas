defmodule ExNylas.Model.ConnectorCredential do
  @moduledoc """
  Structs for Nylas connector credentials.
  """

  use TypedStruct

  typedstruct do
    field(:id, String.t())
    field(:name, String.t())
    field(:created_at, non_neg_integer())
    field(:updated_at, non_neg_integer())
  end

  def as_struct, do: struct(__MODULE__)

  def as_list, do: [as_struct()]

  typedstruct module: Build do
    field(:name, String.t())
    field(:credential_type, String.t())
    field(:credential_data, map())
  end
end
