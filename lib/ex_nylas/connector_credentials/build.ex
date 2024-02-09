defmodule ExNylas.Schema.ConnectorCredential.Build do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :credential_type, :credential_data]}
  @primary_key false

  schema "connector_credential" do
    field :name, :string
    field :credential_type, :string
    field :credential_data, :map
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:name, :credential_type, :credential_data])
  end
end
