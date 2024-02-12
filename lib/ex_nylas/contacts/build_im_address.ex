defmodule ExNylas.Schema.Contact.Build.ImAddress do
  @moduledoc """
  Helper module for validating the IM address subobject on a contact request.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "im_address" do
    field :im_address, :string
    field :type, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:im_address])
    |> validate_length(:im_address, min: 1, max: 255)
  end
end
