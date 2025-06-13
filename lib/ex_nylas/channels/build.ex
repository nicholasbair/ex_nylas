defmodule ExNylas.Channel.Build do
  @moduledoc """
  Helper module for validating a channel before creating/updating it.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/pubsub-notifications)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:description, :trigger_types, :notification_email_addresses, :topic, :encryption_key]}
  @primary_key false

  typed_embedded_schema do
    field(:description, :string)
    field(:notification_email_addresses, {:array, :string})
    field(:encryption_key, :string)
    field(:topic, :string)
    field(:trigger_types, {:array, :string}, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:trigger_types, :topic])
  end
end
