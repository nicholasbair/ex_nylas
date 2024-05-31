defmodule ExNylas.Webhook do
  @moduledoc """
  A struct representing a webhook.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:id, :string, null: false)
    field(:description, :string)
    field(:trigger_types, {:array, :string}, null: false)
    field(:webhook_url, :string, null: false)
    field(:status, Ecto.Enum, values: ~w(active pause failing failed)a, null: false)
    field(:webhook_secret, :string)
    field(:notification_email_addresses, {:array, :string}, null: false)
    field(:topic, :string)
    field(:encryption_key, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :trigger_types, :webhook_url, :status])
  end
end
