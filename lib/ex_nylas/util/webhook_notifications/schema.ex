defmodule ExNylas.WebhookNotification do
  @moduledoc """
  A struct representing an inbound webhook notification.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.WebhookNotificationData, as: Data

  @primary_key false

  typed_embedded_schema do
    field :specversion, :string
    field :type, :string
    field :source, :string
    field :id, :string
    field :time, :integer

    embeds_one :data, Data
  end

  def changeset(struct, params \\ %{}) do
    params
    |> put_trigger()
    |> then(&cast(struct, &1, [:specversion, :type, :source, :id, :time]))
    |> cast_embed(:data)
  end

  # Webhook trigger/type is the most reliable way to determine what notification.data.object should be transformed into.
  # Pass the trigger/type as params so it can be used by polymorphic_embeds_one.
  defp put_trigger(%{"type" => type, "data" => data} = params) do
    %{params | "data" => Map.put(data, "trigger", type)}
  end
end
