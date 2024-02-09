defmodule ExNylas.Schema.Calendar.Build do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:description, :location, :name, :timezone, :metadata]}
  @primary_key false

  schema "calendar" do
    field :description, :string
    field :location, :string
    field :name, :string
    field :timezone, :string
    field :metadata, :map
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:name])
  end
end
