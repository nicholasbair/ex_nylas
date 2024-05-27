defmodule ExNylas.Common.Error do
  @moduledoc """
  A struct representing an error from the Nylas API.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field :type, :string
    field :message, :string
    field :provider_error, :map
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
