defmodule ExNylas.Attachment.Build do
  @moduledoc """
  Helper module for validating an attachment in a draft/message before submitting to the Nylas API.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:id, :content, :content_type, :content_id, :size, :filename, :is_inline]}

  typed_embedded_schema do
    field(:content, :string)
    field(:content_id, :string)
    field(:content_type, :string)
    field(:filename, :string)
    field(:is_inline, :boolean)
    field(:id, :string)
    field(:size, :integer) :: non_neg_integer() | nil
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:content, :content_type, :filename])
  end
end
