defmodule ExNylas.Event do
  @moduledoc """
  A struct representing a event.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field(:busy, :boolean, null: false)
    field(:calendar_id, :string, null: false)
    field(:capacity, :integer)
    field(:created_at, :integer)
    field(:description, :string)
    field(:hide_participants, :boolean)
    field(:grant_id, :string, null: false)
    field(:html_link, :string)
    field(:ical_uid, :string)
    field(:id, :string, null: false)
    field(:location, :string)
    field(:master_event_id, :string)
    field(:metadata, :map)
    field(:object, :string, null: false)
    field(:read_only, :boolean)
    field(:recurrence, {:array, :string})
    field(:status, Ecto.Enum, values: ~w(confirmed canceled maybe)a)
    field(:title, :string)
    field(:updated_at, :integer)
    field(:visibility, Ecto.Enum, values: ~w(public private)a)

    embeds_one :conferencing, Conferencing, primary_key: false do
      field(:meeting_code, :string)
      field(:password, :string)
      field(:phone, {:array, :string})
      field(:pin, :string)
      field(:url, :string)
    end

    embeds_one :organizer, Organizer, primary_key: false do
      field(:email, :string, null: false)
      field(:name, :string)
    end

    embeds_many :participants, Participant, primary_key: false do
      field(:comment, :string)
      field(:email, :string, null: false)
      field(:name, :string)
      field(:phone_number, :string)
      field(:status, Ecto.Enum, values: ~w(yes no maybe noreply)a, null: false)
    end

    embeds_one :reminders, Reminder, primary_key: false do
      field(:overrides, {:array, :map})
      field(:use_default, :boolean, null: false)
    end

    embeds_one :when, When, primary_key: false do
      field(:date, :string)
      field(:end_date, :string)
      field(:end_time, :integer) :: non_neg_integer() | nil
      field(:end_timezone, :string)
      field(:object, Ecto.Enum, values: ~w(time timespan date datespan)a, null: false)
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
    |> cast(params, [:id, :grant_id, :calendar_id, :capacity,:busy, :created_at, :description, :hide_participants, :html_link, :ical_uid, :location, :master_event_id, :metadata, :object, :read_only, :recurrence, :status, :title, :updated_at, :visibility])
    |> cast_embed(:participants, with: &Util.embedded_changeset/2)
    |> cast_embed(:when, with: &Util.embedded_changeset/2)
    |> cast_embed(:conferencing, with: &Util.embedded_changeset/2)
    |> cast_embed(:reminders, with: &Util.embedded_changeset/2)
    |> cast_embed(:organizer, with: &Util.embedded_changeset/2)
    |> validate_required([:id, :grant_id, :calendar_id])
  end
end
