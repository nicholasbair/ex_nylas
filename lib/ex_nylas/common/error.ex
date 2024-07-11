defmodule ExNylas.Error do
  @moduledoc """
  A struct representing an error from the Nylas API.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:message, :string)
    field(:provider_error, :map)
    field(:type, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
