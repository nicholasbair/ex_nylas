defmodule ExNylas.Notetaker.Build do
  @moduledoc """
  Helper module for validating a notetaker before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

  @derive {Jason.Encoder, only: [:meeting_link, :join_time, :name, :meeting_settings]}
  @primary_key false

  typed_embedded_schema do
    field(:meeting_link, :string)
    field(:join_time, :integer)
    field(:name, :string)

    embeds_one :meeting_settings, MeetingSettings, primary_key: false do
      @derive {Jason.Encoder, only: [:video_recording, :audio_recording, :transcription]}

      field(:video_recording, :boolean)
      field(:audio_recording, :boolean)
      field(:transcription, :boolean)
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
    |> cast_embed(:meeting_settings, with: &Util.embedded_changeset/2)
    |> cast_embed(:rules, with: &Util.embedded_changeset/2)
  end
end
