defmodule ExNylas.Grant do
  @moduledoc """
  A struct represting a Nylas grant.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:account_id, :string)
    field(:created_at, :integer, null: false) :: non_neg_integer()
    field(:email, :string, null: false)
    field(:grant_status, Ecto.Enum, values: ~w(valid invalid)a, null: false)
    field(:id, :string, null: false)
    field(:ip, :string)
    field(:provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud yahoo zoom ews)a, null: false)
    field(:provider_user_id, :string)
    field(:scope, {:array, :string})
    field(:settings, :map)
    field(:state, :string)
    field(:updated_at, :integer, null: false) :: non_neg_integer()
    field(:user_agent, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :provider, :grant_status])
  end
end
