defmodule ExNylas.Event.Build do
  @moduledoc """
  Helper module for validating an event before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util
  alias ExNylas.EventReminder.Build, as: EventReminderBuild
  alias ExNylas.EventConferencing.Build, as: EventConferencingBuild
  alias ExNylas.Notetaker.Build, as: NotetakerBuild

  @derive {Jason.Encoder, only: [:capacity, :title, :description, :location, :busy, :recurrence, :visibility, :metadata, :notifications, :hide_participants, :when, :conferencing, :reminders, :participants]}
  @primary_key false

  typed_embedded_schema do
    field(:busy, :boolean)
    field(:capacity, :integer)
    field(:description, :string)
    field(:hide_participants, :boolean)
    field(:location, :string)
    field(:metadata, :map)
    field(:notifications, {:array, :map})
    field(:recurrence, {:array, :string})
    field(:title, :string)
    field(:visibility, :string)

    embeds_one :conferencing, EventConferencingBuild

    embeds_many :participants, Participant do
      @derive {Jason.Encoder, only: [:name, :email, :status, :comment, :phone_number]}

      field(:comment, :string)
      field(:email, :string, null: false)
      field(:name, :string)
      field(:phone_number, :string)
      field(:status, :string)
    end

    embeds_one :reminders, EventReminderBuild
    embeds_one :notetaker, NotetakerBuild

    embeds_one :when, When do
      @derive {Jason.Encoder, only: [:start_time, :end_time, :start_timezone, :end_timezone, :object, :time, :timezone, :start_date, :end_date, :date]}

      field(:date, :string)
      field(:end_date, :string)
      field(:end_time, :integer) :: non_neg_integer() | nil
      field(:end_timezone, :string)
      field(:object, :string)
      field(:start_date, :string)
      field(:start_time, :integer) :: non_neg_integer() | nil
      field(:start_timezone, :string)
      field(:time, :integer) :: non_neg_integer() | nil
      field(:timezone, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:capacity, :title, :description, :location, :busy, :recurrence, :visibility, :metadata, :notifications, :hide_participants, :master_event_id])
    |> cast_embed(:participants, with: &Util.embedded_changeset/2)
    |> cast_embed(:conferencing)
    |> cast_embed(:reminders)
    |> cast_embed(:when, with: &Util.embedded_changeset/2)
    |> cast_embed(:notetaker)
    |> validate_required([:when])
  end
end
