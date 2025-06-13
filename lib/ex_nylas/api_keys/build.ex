defmodule ExNylas.APIKeys.Build do
  @moduledoc """
  Builds API keys for an application.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/manage-api-keys)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :expires_in]}
  @primary_key false

  typed_embedded_schema do
    field(:name, :string)
    field(:expires_in, :integer) :: non_neg_integer()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :expires_in])
  end
end
