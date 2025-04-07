defmodule ExNylas.Notetaker do
  @moduledoc """
  A struct representing a notetaker.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:created_at, :integer)
    field(:grant_id, :string)
    field(:name, :string)
    field(:join_time, :integer)
    field(:meeting_link, :string)
    field(:meeting_provider, Ecto.Enum, values: [:"Google Meet", :"Zoom Meeting", :"Microsoft Teams"])
    field(:status, Ecto.Enum, values: [:scheduled, :connecting, :waiting_for_entry, :failed_entry, :attending, :media_processing, :media_available, :media_error, :media_deleted])

    embeds_one :meeting_settings, MeetingSettings, primary_key: false do
      field(:video_recording, :boolean)
      field(:audio_recording, :boolean)
      field(:transcription, :boolean)
    end

    embeds_one :rules, Rules, primary_key: false do
      field(:event_selection, Ecto.Enum, values: [:internal, :external, :own_events, :participant_only, :all])

      embeds_one :participant_filter, ParticipantFilter, primary_key: false do
        field(:participants_gte, :integer)
        field(:participants_lte, :integer)
      end
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :created_at, :grant_id, :name, :join_time, :meeting_link, :meeting_provider, :status])
    |> cast_embed(:meeting_settings, with: &Util.embedded_changeset/2)
    |> cast_embed(:rules, with: &cast_rules/2)
  end

  defp cast_rules(changeset, params) do
    changeset
    |> cast(params, [:event_selection])
    |> cast_embed(:participant_filter, with: &Util.embedded_changeset/2)
  end
end
