defmodule ExNylas.Webhook do
  @moduledoc """
  A struct representing a webhook.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/webhook-notifications)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:description, :string)
    field(:id, :string)
    field(:notification_email_addresses, {:array, :string})
    field(:status, Ecto.Enum, values: ~w(active pause failing failed)a)
    field(:trigger_types, {:array, :string})
    field(:webhook_url, :string)
    field(:webhook_secret, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
