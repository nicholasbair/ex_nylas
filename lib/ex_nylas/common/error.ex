defmodule ExNylas.Common.Error do
  @moduledoc """
  A struct representing an error from the Nylas API.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:message, :string, null: false)
    field(:provider_error, :map)
    field(:type, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
