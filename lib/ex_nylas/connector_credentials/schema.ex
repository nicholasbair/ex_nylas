defmodule ExNylas.Schema.ConnectorCredential do
  @moduledoc """
  Structs for Nylas connector credentials.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "connector_credential" do
    field :id, :string
    field :name, :string
    field :credential_type, Ecto.Enum, values: ~w(adminconsent serviceaccount)a
    field :hashed_data, :string
    field :created_at, :integer
    field :updated_at, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id])
  end
end
