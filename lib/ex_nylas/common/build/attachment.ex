defmodule ExNylas.Common.Build.Attachment do
  @moduledoc """
  Helper module for validating an attachment in a draft/message before submitting to the Nylas API.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:id, :content, :content_type, :size, :filename, :is_inline]}

  embedded_schema do
    field :id, :string
    field :content, :string
    field :content_type, :string
    field :size, :integer
    field :filename, :string
    field :is_inline, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:content, :content_type, :filename])
  end
end
