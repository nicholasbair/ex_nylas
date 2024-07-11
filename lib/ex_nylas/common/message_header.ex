defmodule ExNylas.MessageHeader do
  @moduledoc """
  A struct representing the headers of a message.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:name, :string)
    field(:value, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
