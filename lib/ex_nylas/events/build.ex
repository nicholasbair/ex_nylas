defmodule ExNylas.Schema.Event.Build do
  @moduledoc """
  Helper module for validating an event before creating/updating it.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Schema.Util
  alias ExNylas.Common.Build.EventReminder
  alias ExNylas.Common.Build.EventConferencing

  @type t :: %__MODULE__{
          title: String.t(),
          description: String.t(),
          location: String.t(),
          busy: boolean(),
          recurrence: list(String.t()),
          visibility: String.t(),
          metadata: map(),
          notifications: list(map()),
          hide_participants: boolean(),
          when: %__MODULE__.When{
            start_time: non_neg_integer(),
            end_time: non_neg_integer(),
            start_timezone: String.t(),
            end_timezone: String.t(),
            object: String.t(),
            time: non_neg_integer(),
            timezone: String.t(),
            start_date: String.t(),
            end_date: String.t(),
            date: String.t()
          },
          conferencing: EventConferencing.t(),
          reminders: EventReminder.t(),
          participants: [
            %__MODULE__.Participant{
              name: String.t(),
              email: String.t(),
              status: String.t(),
              comment: String.t(),
              phone_number: String.t()
            }
          ],
          master_event_id: String.t()
        }

  @derive {Jason.Encoder, only: [:title, :description, :location, :busy, :recurrence, :visibility, :metadata, :notifications, :hide_participants, :when, :conferencing, :reminders, :participants, :master_event_id]}
  @primary_key false

  embedded_schema do
    field :title, :string
    field :description, :string
    field :location, :string
    field :busy, :boolean
    field :recurrence, {:array, :string}
    field :visibility, :string
    field :metadata, :map
    field :notifications, {:array, :map}
    field :hide_participants, :boolean
    field :master_event_id, :string

    embeds_many :participants, Participant do
      @derive {Jason.Encoder, only: [:name, :email, :status, :comment, :phone_number]}

      field :name, :string
      field :email, :string
      field :status, :string
      field :comment, :string
      field :phone_number, :string
    end

    embeds_one :conferencing, EventConferencing
    embeds_one :reminders, EventReminder

    embeds_one :when, When do
      @derive {Jason.Encoder, only: [:start_time, :end_time, :start_timezone, :end_timezone, :object, :time, :timezone, :start_date, :end_date, :date]}

      field :start_time, :integer
      field :end_time, :integer
      field :start_timezone, :string
      field :end_timezone, :string
      field :object, :string
      field :time, :integer
      field :timezone, :string
      field :start_date, :string
      field :end_date, :string
      field :date, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :description, :location, :busy, :recurrence, :visibility, :metadata, :notifications, :hide_participants, :master_event_id])
    |> cast_embed(:participants, with: &Util.embedded_changeset/2)
    |> cast_embed(:conferencing)
    |> cast_embed(:reminders)
    |> cast_embed(:when, with: &Util.embedded_changeset/2)
    |> validate_required([:when])
  end
end
