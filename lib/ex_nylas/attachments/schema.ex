defmodule ExNylas.Attachment do
  @moduledoc """
  A struct representing an attachment.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:content_disposition, :string)
    field(:content_id, :string)
    field(:content_type, :string, null: false)
    field(:filename, :string, null: false)
    field(:grant_id, :string, null: false)
    field(:id, :string, null: false)
    field(:is_inline, :boolean, null: false)
    field(:size, :integer, null: false) :: non_neg_integer()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :grant_id])
  end
end
