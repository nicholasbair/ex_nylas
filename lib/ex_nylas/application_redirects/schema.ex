defmodule ExNylas.ApplicationRedirect do
  @moduledoc """
  A struct for Nylas application redirect.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string, null: false)
    field(:platform, Ecto.Enum, values: ~w(web desktop js ios android)a, null: false)
    field(:url, :string, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:url, :id])
  end
end
