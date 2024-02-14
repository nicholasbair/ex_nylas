defmodule ExNylas.Attachment do
  @moduledoc """
  A struct representing an attachment.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :id, :string
    field :grant_id, :string
    field :content_type, :string
    field :size, :integer
    field :filename, :string
    field :is_inline, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id])
  end
end
