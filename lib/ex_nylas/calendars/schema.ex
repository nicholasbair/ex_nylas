defmodule ExNylas.Calendar do
  @moduledoc """
  A struct representing a calendar.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:description, :string)
    field(:grant_id, :string)
    field(:hex_color, :string)
    field(:hex_foreground_color, :string)
    field(:id, :string)
    field(:is_owned_by_user, :boolean)
    field(:is_primary, :boolean)
    field(:location, :string)
    field(:metadata, :map)
    field(:name, :string)
    field(:object, :string)
    field(:read_only, :boolean)
    field(:timezone, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
