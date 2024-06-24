defmodule ExNylas.Channel do
  @moduledoc """
  A struct representing a channel.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:description, :string)
    field(:id, :string, null: false)
    field(:notification_email_addresses, {:array, :string}, null: false)
    field(:status, Ecto.Enum, values: ~w(active pause failing failed)a, null: false)
    field(:topic, :string)
    field(:trigger_types, {:array, :string}, null: false)
    field(:created_at, :integer)
    field(:updated_at, :integer)
    field(:status_updated_at, :integer)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :trigger_types, :webhook_url, :status, :created_at, :updated_at, :status_updated_at])
  end
end
