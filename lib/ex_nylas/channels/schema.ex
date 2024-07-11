defmodule ExNylas.Channel do
  @moduledoc """
  A struct representing a channel.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:description, :string)
    field(:id, :string)
    field(:notification_email_addresses, {:array, :string})
    field(:status, Ecto.Enum, values: ~w(active pause failing failed)a)
    field(:topic, :string)
    field(:trigger_types, {:array, :string})
    field(:created_at, :integer)
    field(:updated_at, :integer)
    field(:status_updated_at, :integer)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
