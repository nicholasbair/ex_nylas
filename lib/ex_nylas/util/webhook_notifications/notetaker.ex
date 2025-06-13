defmodule ExNylas.WebhookNotification.Notetaker do
  @moduledoc """
  Schema for notetaker notification.

  [Nylas docs](https://developer.nylas.com/docs/v3/notifications/notification-schemas/#notetaker-notifications)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:grant_id, :string)
    field(:join_time, :integer) :: non_neg_integer()
    field(:calendar_id, :string)
    field(:object, :string)
    field(:state, Ecto.Enum, values: [:attending, :connecting, :disconnected, :failed_entry, :scheduled, :waiting_for_entry])
    field(:meeting_state, Ecto.Enum, values: [:api_request, :bad_meeting_code, :dispatched, :entry_denied, :internal_error, :kicked, :no_meeting_activity, :no_participants, :no_response, :recording_active, :waiting_for_entry])

    embeds_one :meeting_settings, MeetingSettings, primary_key: false do
      field(:video_recording, :boolean)
      field(:audio_recording, :boolean)
      field(:transcription, :boolean)
    end

    embeds_one :event, Event, primary_key: false do
      field(:ical_uid, :string)
      field(:event_id, :string)
      field(:master_event_id, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :grant_id, :join_time, :calendar_id, :object, :state, :meeting_state])
    |> cast_embed(:meeting_settings, with: &embedded_changeset/2)
    |> cast_embed(:event, with: &embedded_changeset/2)
  end
end
