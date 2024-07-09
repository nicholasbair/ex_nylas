defmodule ExNylas.RoomResource do
  @moduledoc """
  Structs for Nylas room resources.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:building, :string)
    field(:capacity, :integer)
    field(:email, :string)
    field(:floor_name, :string)
    field(:floor_number, :integer)
    field(:floor_section, :string)
    field(:grant_id, :string, null: false)
    field(:object, :string, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
