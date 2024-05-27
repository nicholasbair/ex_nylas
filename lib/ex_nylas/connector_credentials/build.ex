defmodule ExNylas.ConnectorCredential.Build do
  @moduledoc """
  Helper module for validating a connector credential before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :credential_type, :credential_data]}
  @primary_key false

  typed_embedded_schema do
    field :name, :string
    field :credential_type, Ecto.Enum, values: ~w(adminconsent serviceaccount)a
    field :credential_data, :map
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:name, :credential_type, :credential_data])
  end
end
