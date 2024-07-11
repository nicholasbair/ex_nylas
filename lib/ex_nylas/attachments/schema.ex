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
    field(:content_type, :string)
    field(:filename, :string)
    field(:grant_id, :string)
    field(:id, :string)
    field(:is_inline, :boolean)
    field(:size, :integer) :: non_neg_integer() | nil
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
