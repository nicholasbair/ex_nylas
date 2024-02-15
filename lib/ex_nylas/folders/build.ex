defmodule ExNylas.Folder.Build do
  @moduledoc """
  Helper module for validating a folder before creating/updating it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :parent_id, :background_color, :text_color]}
  @primary_key false

  embedded_schema do
    field :name, :string
    field :parent_id, :string
    field :background_color, :string
    field :text_color, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:name])
  end
end
