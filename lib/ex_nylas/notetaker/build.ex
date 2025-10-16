defmodule ExNylas.Notetaker.Build do
  @moduledoc """
  Helper module for validating a notetaker before creating/updating it.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/notetaker)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util
  alias ExNylas.Notetaker.CustomSettings

  @derive {Jason.Encoder, only: [:meeting_link, :join_time, :name, :meeting_settings, :rules]}
  @primary_key false

  typed_embedded_schema do
    field(:meeting_link, :string)
    field(:join_time, :integer)
    field(:name, :string)

    embeds_one :meeting_settings, MeetingSettings, primary_key: false do
      @derive {Jason.Encoder, only: [:video_recording, :audio_recording, :transcription, :action_items, :summary, :action_item_settings, :summary_settings]}

      field(:video_recording, :boolean)
      field(:audio_recording, :boolean)
      field(:transcription, :boolean)
      field(:action_items, :boolean)
      field(:summary, :boolean)

      embeds_one :action_item_settings, CustomSettings
      embeds_one :summary_settings, CustomSettings
    end

    embeds_one :rules, Rules, primary_key: false do
      @derive {Jason.Encoder, only: [:event_selection, :participant_filter]}

      field(:event_selection, Ecto.Enum, values: [:internal, :external, :own_events, :participant_only, :all])

      embeds_one :participant_filter, ParticipantFilter, primary_key: false do
        @derive {Jason.Encoder, only: [:participants_gte, :participants_lte]}

        field(:participants_gte, :integer)
        field(:participants_lte, :integer)
      end
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :join_time, :meeting_link])
    |> validate_required([:meeting_link])
    |> cast_embed(:meeting_settings, with: &cast_meeting_settings/2)
    |> cast_embed(:rules, with: &Util.embedded_changeset/2)
  end

  defp cast_meeting_settings(changeset, params) do
    changeset
    |> cast(params, [:video_recording, :audio_recording, :transcription, :action_items, :summary])
    |> cast_embed(:action_item_settings, with: &Util.embedded_changeset/2)
    |> cast_embed(:summary_settings, with: &Util.embedded_changeset/2)
  end
end
