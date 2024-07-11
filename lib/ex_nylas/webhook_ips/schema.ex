defmodule ExNylas.WebhookIP do
  @moduledoc """
  A struct for Nylas webhook IP.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:ip_addresses, {:array, :string})
    field(:updated_at, :integer) :: non_neg_integer() | nil
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
