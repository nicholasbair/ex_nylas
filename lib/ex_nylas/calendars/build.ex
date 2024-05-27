defmodule ExNylas.Calendar.Build do
  @moduledoc """
  Helper module for validating a calendar before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:description, :location, :name, :timezone, :metadata]}
  @primary_key false

  typed_embedded_schema do
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
