defmodule ExNylas.Schema.Connector.Build do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:provider, :settings, :scope]}
  @primary_key false

  schema "connector" do
    field :provider, :string
    field :settings, :map
    field :scope, {:array, :string}
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:provider, :settings])
  end
end
