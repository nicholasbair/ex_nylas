defmodule ExNylas.Calendar do
  @moduledoc """
  A struct representing a calendar.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          grant_id: String.t(),
          description: String.t(),
          id: String.t(),
          is_primary: boolean(),
          location: String.t(),
          name: String.t(),
          object: String.t(),
          read_only: boolean(),
          timezone: String.t(),
          hex_color: String.t(),
          hex_foreground_color: String.t(),
          is_owned_by_user: boolean(),
          metadata: map()
        }

  @primary_key false

  embedded_schema do
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

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :grant_id])
  end
end
