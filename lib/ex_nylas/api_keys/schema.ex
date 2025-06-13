defmodule ExNylas.APIKey do
  @moduledoc """
  A struct representing an API key.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/manage-api-keys)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:api_key, :string)
    field(:application_id, :string)
    field(:created_at, :integer) :: non_neg_integer()
    field(:updated_at, :integer) :: non_neg_integer()
    field(:expires_at, :integer) :: non_neg_integer()
    field(:name, :string)
    field(:status, Ecto.Enum, values: ~w(active inactive)a)
    field(:permissions, {:array, :string})
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:api_key, :application_id, :created_at, :updated_at, :expires_at, :name, :status, :permissions])
  end
end
