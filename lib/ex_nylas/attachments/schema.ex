defmodule ExNylas.Schema.Attachment do
  @moduledoc """
  A struct representing an attachment.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "attachment" do
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
    |> validate_required([:id, :grant_id])
  end
end