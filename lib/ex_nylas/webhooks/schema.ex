defmodule ExNylas.Webhook do
  @moduledoc """
  A struct representing a webhook.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "webhook" do
    field :id, :string
    field :description, :string
    field :trigger_types, {:array, :string}
    field :webhook_url, :string
    field :status, Ecto.Enum, values: ~w(active pause failing failed)a
    field :webhook_secret, :string
    field :notification_email_addresses, {:array, :string}
    field :topic, :string
    field :encryption_key, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :trigger_types, :webhook_url, :status])
  end
end
