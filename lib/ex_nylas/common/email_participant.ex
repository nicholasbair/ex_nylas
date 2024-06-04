defmodule ExNylas.Common.EmailParticipant do
  @moduledoc """
  A struct representing an email participant.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:email, :string, null: false)
    field(:name, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:email])
  end
end
