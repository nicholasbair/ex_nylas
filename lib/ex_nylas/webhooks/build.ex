defmodule ExNylas.Webhook.Build do
  @moduledoc """
  Helper module for validating a webhook before creating/updating it.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/webhook-notifications)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:description, :trigger_types, :webhook_url, :notification_email_addresses]}
  @primary_key false

  typed_embedded_schema do
    field(:description, :string)
    field(:notification_email_addresses, {:array, :string})
    field(:trigger_types, {:array, :string}, null: false)
    field(:webhook_url, :string, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:trigger_types, :webhook_url])
  end
end
