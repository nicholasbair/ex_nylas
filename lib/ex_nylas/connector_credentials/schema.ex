defmodule ExNylas.ConnectorCredential do
  @moduledoc """
  Structs for Nylas connector credentials.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:created_at, :integer) :: non_neg_integer()
    field(:credential_type, Ecto.Enum, values: ~w(adminconsent serviceaccount)a, null: false)
    field(:hashed_data, :string)
    field(:id, :string, null: false)
    field(:name, :string, null: false)
    field(:updated_at, :integer) :: non_neg_integer()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id])
  end
end
