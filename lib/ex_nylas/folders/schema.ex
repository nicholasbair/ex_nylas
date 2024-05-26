defmodule ExNylas.Folder do
  @moduledoc """
  A struct representing a folder.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          grant_id: String.t(),
          system_folder: boolean(),
          total_count: integer(),
          unread_count: integer(),
          child_count: integer(),
          parent_id: String.t(),
          background_color: String.t(),
          object: String.t(),
          text_color: String.t()
        }

  @primary_key false

  embedded_schema do
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
