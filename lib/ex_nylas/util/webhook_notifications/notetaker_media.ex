defmodule ExNylas.WebhookNotification.NotetakerMedia do
  @moduledoc """
  Schema for notetaker media notification.

  [Nylas docs](https://developer.nylas.com/docs/v3/notifications/notification-schemas/#notetaker-notifications)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:grant_id, :string)
    field(:object, :string)
    field(:state, Ecto.Enum, values: [:available, :deleted, :error, :processing])

    embeds_one :media, Media, primary_key: false do
      field(:recording, :string)
      field(:transcript, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :grant_id, :object, :state])
    |> cast_embed(:media, with: &embedded_changeset/2)
  end
end
