defmodule ExNylas.Folder do
  @moduledoc """
  A struct representing a folder.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string, null: false)
    field(:name, :string, null: false)
    field(:grant_id, :string, null: false)
    field(:system_folder, :boolean)
    field(:total_count, :integer) :: non_neg_integer() | nil
    field(:unread_count, :integer) :: non_neg_integer() | nil
    field(:child_count, :integer) :: non_neg_integer() | nil
    field(:parent_id, :string)
    field(:background_color, :string)
    field(:object, :string, null: false)
    field(:text_color, :string)
    field(:attributes, {:array, :string})
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :grant_id])
  end
end
