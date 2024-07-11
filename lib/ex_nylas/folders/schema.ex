defmodule ExNylas.Folder do
  @moduledoc """
  A struct representing a folder.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:attributes, {:array, :string})
    field(:background_color, :string)
    field(:child_count, :integer) :: non_neg_integer() | nil
    field(:grant_id, :string)
    field(:id, :string)
    field(:name, :string)
    field(:object, :string)
    field(:parent_id, :string)
    field(:system_folder, :boolean)
    field(:text_color, :string)
    field(:total_count, :integer) :: non_neg_integer() | nil
    field(:unread_count, :integer) :: non_neg_integer() | nil
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
