defmodule ExNylas.Calendar do
  @moduledoc """
  A struct representing a calendar.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:description, :string)
    field(:grant_id, :string, null: false)
    field(:hex_color, :string)
    field(:hex_foreground_color, :string)
    field(:id, :string, null: false)
    field(:is_owned_by_user, :boolean, null: false)
    field(:is_primary, :boolean, null: false)
    field(:location, :string)
    field(:metadata, :map)
    field(:name, :string, null: false)
    field(:object, :string, null: false)
    field(:read_only, :boolean, null: false)
    field(:timezone, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :grant_id])
  end
end
