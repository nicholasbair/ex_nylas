defmodule ExNylas.Webhook do
  @moduledoc """
  A struct representing a webhook.
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
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
