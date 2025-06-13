defmodule ExNylas.Folder.Build do
  @moduledoc """
  Helper module for validating a folder before creating/updating it.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/folders)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :parent_id, :background_color, :text_color]}
  @primary_key false

  typed_embedded_schema do
    field(:background_color, :string)
    field(:name, :string, null: false)
    field(:parent_id, :string)
    field(:text_color, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:name])
  end
end
