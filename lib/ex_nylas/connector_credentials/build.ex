defmodule ExNylas.ConnectorCredential.Build do
  @moduledoc """
  Helper module for validating a connector credential before creating/updating it.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/connector-credentials)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :credential_type, :credential_data]}
  @primary_key false

  typed_embedded_schema do
    field(:credential_data, :map, null: false)
    field(:credential_type, Ecto.Enum, values: ~w(adminconsent serviceaccount)a, null: false)
    field(:name, :string, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:name, :credential_type, :credential_data])
  end
end
