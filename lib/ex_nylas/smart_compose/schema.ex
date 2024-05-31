defmodule ExNylas.Schema.SmartCompose do
  @moduledoc """
  A struct for Nylas smart compose.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:suggestion, :string, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:suggestion])
  end
end
