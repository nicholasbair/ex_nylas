defmodule ExNylas.Webhook.Build do
  @moduledoc """
  Helper module for validating a webhook before creating/updating it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          description: String.t(),
          trigger_types: [String.t()],
          webhook_url: String.t(),
          notification_email_addresses: [String.t()],
          topic: String.t(),
          encryption_key: String.t()
        }

  @derive {Jason.Encoder, only: [:description, :trigger_types, :webhook_url, :notification_email_addresses, :topic, :encryption_key]}
  @primary_key false

  schema "webhook" do
    field :description, :string
    field :trigger_types, {:array, :string}
    field :webhook_url, :string
    field :notification_email_addresses, {:array, :string}
    field :topic, :string
    field :encryption_key, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:trigger_types, :webhook_url])
  end
end
