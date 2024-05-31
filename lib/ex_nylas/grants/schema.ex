defmodule ExNylas.Grant do
  @moduledoc """
  A struct represting a Nylas grant.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string, null: false)
    field(:provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud yahoo)a, null: false)
    field(:grant_status, Ecto.Enum, values: ~w(valid invalid)a, null: false)
    field(:email, :string, null: false)
    field(:scope, {:array, :string})
    field(:user_agent, :string)
    field(:ip, :string)
    field(:state, :string)
    field(:created_at, :integer, null: false) :: non_neg_integer()
    field(:updated_at, :integer, null: false) :: non_neg_integer()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :provider, :scope, :grant_status])
  end
end
