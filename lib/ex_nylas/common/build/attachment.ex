defmodule ExNylas.Common.Build.Attachment do
  @moduledoc """
  Helper module for validating an attachment in a draft/message before submitting to the Nylas API.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          content_id: String.t(),
          content: String.t(),
          content_type: String.t(),
          size: non_neg_integer(),
          filename: String.t(),
          is_inline: boolean()
        }

  @primary_key false
  @derive {Jason.Encoder, only: [:id, :content, :content_type, :content_id, :size, :filename, :is_inline]}

  embedded_schema do
    field :id, :string
    field :content_id, :string
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
