defmodule ExNylas.Calendar.Build do
  @moduledoc """
  Helper module for validating a calendar before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util
  alias ExNylas.Notetaker.Build, as: NotetakerBuild

  @derive {Jason.Encoder, only: [:description, :location, :name, :timezone, :metadata, :notetaker]}
  @primary_key false

  typed_embedded_schema do
    field(:description, :string)
    field(:location, :string)
    field(:metadata, :map)
    field(:name, :string, null: false)
    field(:timezone, :string)

    embeds_one :notetaker, NotetakerBuild
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:description, :location, :name, :timezone, :metadata])
    |> cast_embed(:notetaker, with: &Util.embedded_changeset/2)
    |> validate_required([:name])
  end
end
