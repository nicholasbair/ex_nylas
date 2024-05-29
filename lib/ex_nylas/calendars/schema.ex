defmodule ExNylas.Calendar do
  @moduledoc """
  A struct representing a calendar.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field :grant_id, :string
    field :description, :string
    field :id, :string
    field :is_primary, :boolean
    field :location, :string
    field :name, :string
    field :object, :string
    field :read_only, :boolean
    field :timezone, :string
    field :hex_color, :string
    field :hex_foreground_color, :string
    field :is_owned_by_user, :boolean
    field :metadata, :map
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :grant_id])
  end
end
