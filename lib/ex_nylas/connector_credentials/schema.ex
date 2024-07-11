defmodule ExNylas.ConnectorCredential do
  @moduledoc """
  Structs for Nylas connector credentials.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:created_at, :integer) :: non_neg_integer() | nil
    field(:credential_type, Ecto.Enum, values: ~w(adminconsent serviceaccount)a)
    field(:hashed_data, :string)
    field(:id, :string)
    field(:name, :string)
    field(:updated_at, :integer) :: non_neg_integer() | nil
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
