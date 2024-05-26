defmodule ExNylas.ContactGroup do
  @moduledoc """
  A struct representing a contact group.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          grant_id: String.t(),
          group_type: String.t(),
          id: String.t(),
          name: String.t(),
          object: String.t(),
          path: String.t()
        }

  @primary_key false

  embedded_schema do
    field :grant_id, :string
    field :group_type, Ecto.Enum, values: ~w(system user other)a
    field :id, :string
    field :name, :string
    field :object, :string
    field :path, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :grant_id])
  end
end
