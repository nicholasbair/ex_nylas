defmodule ExNylas.EmailParticipant.Build do
  @moduledoc """
  Helper module for building an email participant.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:email, :name]}

  typed_embedded_schema do
    field(:email, :string, null: false)
    field(:name, :string)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:email])
  end
end
