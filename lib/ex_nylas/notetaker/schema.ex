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
    field(:status, Ecto.Enum, values: [:scheduled, :joining, :waiting_for_admission, :attending, :leaving, :concluded])

    embeds_one :meeting_settings, MeetingSettings, primary_key: false do
      field(:video_recording, :boolean)
      field(:audio_recording, :boolean)
      field(:transcription, :boolean)
      field(:summary, :boolean)
      field(:action_items, :boolean)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :notetaker_name, :join_time, :meeting_link, :meeting_provider, :status])
    |> cast_embed(:meeting_settings, with: &Util.embedded_changeset/2)
  end
end
