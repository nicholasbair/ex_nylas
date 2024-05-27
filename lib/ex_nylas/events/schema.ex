defmodule ExNylas.Event do
  @moduledoc """
  A struct representing a event.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field :id, :string
    field :object, :string
    field :grant_id, :string
    field :calendar_id, :string
    field :title, :string
    field :description, :string
    field :location, :string
    field :busy, :boolean
    field :recurrence, {:array, :string}
    field :visibility, Ecto.Enum, values: ~w(public private)a
    field :metadata, :map
    field :notifications, {:array, :map}
    field :hide_participants, :boolean
    field :master_event_id, :string

    embeds_many :participants, Participant, primary_key: false do
      field :name, :string
      field :email, :string
      field :status, Ecto.Enum, values: ~w(yes no maybe noreply)a
      field :comment, :string
      field :phone_number, :string
    end

    embeds_one :when, When, primary_key: false do
      field :start_time, :integer
      field :end_time, :integer
      field :start_timezone, :string
      field :end_timezone, :string
      field :object, Ecto.Enum, values: ~w(time timespan date datespan)a
      field :time, :integer
      field :timezone, :string
      field :start_date, :string
      field :end_date, :string
      field :date, :string
    end

    embeds_one :conferencing, Conferencing, primary_key: false do
      field :meeting_code, :string
      field :password, :string
      field :url, :string
      field :phone, {:array, :string}
      field :pin, :string
    end

    embeds_one :reminders, Reminder, primary_key: false do
      field :overrides, {:array, :map}
      field :use_default, :boolean
    end

    embeds_one :organizer, Organizer, primary_key: false do
      field :email, :string
      field :name, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :object, :grant_id, :calendar_id, :title, :description, :location, :busy, :recurrence, :visibility, :metadata, :notifications, :hide_participants, :master_event_id])
    |> cast_embed(:participants, with: &Util.embedded_changeset/2)
    |> cast_embed(:when, with: &Util.embedded_changeset/2)
    |> cast_embed(:conferencing, with: &Util.embedded_changeset/2)
    |> cast_embed(:reminders, with: &Util.embedded_changeset/2)
    |> cast_embed(:organizer, with: &Util.embedded_changeset/2)
    |> validate_required([:id, :grant_id, :calendar_id])
  end
end
