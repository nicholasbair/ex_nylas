defmodule ExNylas.Grant do
  @moduledoc """
  A struct represting a Nylas grant.

  https://developer.nylas.com/docs/api/v3/admin/#tag/manage-grants
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:account_id, :string)
    field(:created_at, :integer) :: non_neg_integer() | nil
    field(:email, :string)
    field(:grant_status, Ecto.Enum, values: ~w(valid invalid)a)
    field(:id, :string)
    field(:ip, :string)
    field(:provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud yahoo zoom ews)a)
    field(:provider_user_id, :string)
    field(:scope, {:array, :string})
    field(:settings, :map)
    field(:state, :string)
    field(:updated_at, :integer) :: non_neg_integer() | nil
    field(:user_agent, :string)
    field(:name, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
