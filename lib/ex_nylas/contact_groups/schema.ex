defmodule ExNylas.ContactGroup do
  @moduledoc """
  A struct representing a contact group.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field :grant_id, :string
    field :group_type, Ecto.Enum, values: ~w(system user other)a
    field :id, :string
    field :name, :string
    field :object, :string
    field :path, :string
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :grant_id])
  end
end
