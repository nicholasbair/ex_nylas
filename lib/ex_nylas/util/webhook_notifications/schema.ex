defmodule ExNylas.WebhookNotification do
  @moduledoc """
  A struct representing a webhook notification.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          specversion: String.t(),
          type: String.t(),
          source: String.t(),
          id: String.t(),
          time: integer(),
          data: ExNylas.WebhookNotificationData.t()
        }

  @primary_key false

  embedded_schema do
    field :specversion, :string
    field :type, :string
    field :source, :string
    field :id, :string
    field :time, :integer

    embeds_one :data, ExNylas.WebhookNotificationData
  end

  def changeset(struct, params \\ %{}) do
    params = put_trigger(params)

    struct
    |> cast(params, [:specversion, :type, :source, :id, :time])
    |> cast_embed(:data)
  end

  # Webhook trigger/type is the most reliable way to determine what notification.data.object should be transformed into.
  # Pass the trigger/type as params so it can be used by polymorphic_embeds_one.
  defp put_trigger(%{"type" => type, "data" => data} = params) do
    data = Map.put(data, "trigger", type)
    %{params | "data" => data}
  end
end
