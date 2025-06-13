defmodule ExNylas.Schema.SmartCompose do
  @moduledoc """
  A struct for Nylas smart compose.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/smart-compose)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:suggestion, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
