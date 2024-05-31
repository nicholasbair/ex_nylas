defmodule ExNylas.WebhookIP do
  @moduledoc """
  A struct for Nylas webhook IP.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:ip_addresses, {:array, :string}, null: false)
    field(:updated_at, :integer, null: false) :: non_neg_integer()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:ip_addresses])
  end
end
