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
    field(:notetaker_name, :string)
    field(:join_time, :integer)
    field(:meeting_link, :string)
    field(:meeting_provider, Ecto.Enum, values: [:"Google Meet"])
    field(:notetaker_state, Ecto.Enum, values: [:scheduled, :joining, :waiting_for_admission, :attending, :leaving, :done])

    embeds_one :meeting_settings, MeetingSettings do
      field(:video_recording, :boolean)
      field(:audio_recording, :boolean)
      field(:transcription, :boolean)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :notetaker_name, :join_time, :meeting_link, :meeting_provider, :notetaker_state])
    |> cast_embed(:meeting_settings, with: &Util.embedded_changeset/2)
  end
end
