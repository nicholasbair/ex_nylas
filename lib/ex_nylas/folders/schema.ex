defmodule ExNylas.Schema.Folder do
  @moduledoc """
  A struct representing a folder.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "folder" do
    field :id, :string
    field :name, :string
    field :grant_id, :string
    field :system_folder, :boolean
    field :total_count, :integer
    field :unread_count, :integer
    field :child_count, :integer
    field :parent_id, :string
    field :background_color, :string
    field :object, :string
    field :text_color, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :grant_id])
  end
end
