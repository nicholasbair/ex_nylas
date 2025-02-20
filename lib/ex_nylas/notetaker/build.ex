defmodule ExNylas.Notetaker.Build do
  @moduledoc """
  Helper module for validating a notetaker before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

  @derive {Jason.Encoder, only: [:meeting_link, :join_time, :notetaker_name, :meeting_settings]}
  @primary_key false

  typed_embedded_schema do
    field(:meeting_link, :string)
    field(:join_time, :integer)
    field(:notetaker_name, :string)

    embeds_one :meeting_settings, MeetingSettings, primary_key: false do
      @derive {Jason.Encoder, only: [:video_recording, :audio_recording, :transcription]}

      field(:video_recording, :boolean)
      field(:audio_recording, :boolean)
      field(:transcription, :boolean)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:notetaker_name, :join_time, :meeting_link])
    |> validate_required([:meeting_link])
    |> cast_embed(:meeting_settings, with: &Util.embedded_changeset/2)
  end
end
