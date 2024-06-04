defmodule ExNylas.Common.MessageHeader do
  @moduledoc """
  A struct representing the headers of a message.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:name, :string, null: false)
    field(:value, :string, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
