defmodule ExNylas.ApplicationRedirect do
  @moduledoc """
  A struct for Nylas application redirect.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:platform, Ecto.Enum, values: ~w(web desktop js ios android)a)
    field(:url, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
