defmodule ExNylas.Event do
  @moduledoc """
  A struct representing a event.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  alias ExNylas.Schema.Util
  alias ExNylas.Event.{
    Conferencing,
    Conferencing.Details,
    Date,
    Datespan,
    Organizer,
    Participant,
    Reminder,
    Timespan
  }

  # TypedEctoSchema and PolymorphicEmbed don't play nice together, so explicitly define the type
  @type t :: %__MODULE__{
          busy: boolean() | nil,
          calendar_id: String.t() | nil,
          capacity: integer() | nil,
          created_at: integer() | nil,
          description: String.t() | nil,
          text_description: String.t() | nil,
          hide_participants: boolean() | nil,
          grant_id: String.t() | nil,
          html_link: String.t() | nil,
          ical_uid: String.t() | nil,
          id: String.t() | nil,
          location: String.t() | nil,
          master_event_id: String.t() | nil,
          metadata: %{optional(String.t()) => String.t()},
          object: String.t() | nil,
          occurrences: [String.t()] | nil,
          read_only: boolean() | nil,
          recurrence: [String.t()] | nil,
          status: :confirmed | :canceled | :maybe,
          title: String.t() | nil,
          updated_at: integer() | nil,
          visibility: :public | :private | :default,
          conferencing: conferencing() | nil,
          organizer: organizer() | nil,
          participants: [participant()] | nil,
          reminders: reminder() | nil,
          when: Date.t() | Datespan.t() | Timespan.t() | nil
        }

  @type conferencing :: %Conferencing{
          provider: String.t() | nil,
          details: details() | nil
        }

  @type details :: %Details{
          meeting_code: String.t() | nil,
          password: String.t() | nil,
          phone: [String.t()] | nil,
          pin: String.t() | nil,
          url: String.t() | nil
        }

  @type organizer :: %Organizer{
          email: String.t() | nil,
          name: String.t() | nil
        }

  @type participant :: %Participant{
          comment: String.t() | nil,
          email: String.t() | nil,
          name: String.t() | nil,
          phone_number: String.t() | nil,
          status: :yes | :no | :maybe | :noreply
        }

  @type reminder :: %Reminder{
          overrides: [map()] | nil,
          use_default: boolean() | nil
        }

  @primary_key false

  embedded_schema do
    field(:busy, :boolean)
    field(:calendar_id, :string)
    field(:capacity, :integer)
    field(:created_at, :integer)
    field(:description, :string)
    field(:hide_participants, :boolean)
    field(:grant_id, :string)
    field(:html_link, :string)
    field(:ical_uid, :string)
    field(:id, :string)
    field(:location, :string)
    field(:master_event_id, :string)
    field(:metadata, :map)
    field(:object, :string)
    field(:occurrences, {:array, :string})
    field(:read_only, :boolean)
    field(:recurrence, {:array, :string})
    field(:status, Ecto.Enum, values: ~w(confirmed canceled maybe)a)
    field(:text_description, :string)
    field(:title, :string)
    field(:updated_at, :integer)
    field(:visibility, Ecto.Enum, values: ~w(public private default)a)

    embeds_one :conferencing, Conferencing, primary_key: false do
      field(:provider, :string)

      embeds_one :details, Details, primary_key: false do
        field(:meeting_code, :string)
        field(:password, :string)
        field(:phone, {:array, :string})
        field(:pin, :string)
        field(:url, :string)
      end
    end

    embeds_one :organizer, Organizer, primary_key: false do
      field(:email, :string)
      field(:name, :string)
    end

    embeds_many :participants, Participant, primary_key: false do
      field(:comment, :string)
      field(:email, :string)
      field(:name, :string)
      field(:phone_number, :string)
      field(:status, Ecto.Enum, values: ~w(yes no maybe noreply)a)
    end

    embeds_one :reminders, Reminder, primary_key: false do
      field(:overrides, {:array, :map})
      field(:use_default, :boolean)
    end

    polymorphic_embeds_one :when,
      types: [
        date: Date,
        datespan: Datespan,
        timespan: Timespan
      ],
      type_field_name: :object,
      on_type_not_found: :changeset_error,
      on_replace: :update
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :grant_id, :calendar_id, :capacity, :busy, :created_at, :description, :hide_participants, :html_link, :ical_uid, :location, :master_event_id, :metadata, :object, :occurrences, :read_only, :recurrence, :status, :text_description, :title, :updated_at, :visibility])
    |> cast_embed(:participants, with: &Util.embedded_changeset/2)
    |> cast_polymorphic_embed(:when)
    |> cast_embed(:conferencing, with: &conferencing_changeset/2)
    |> cast_embed(:reminders, with: &Util.embedded_changeset/2)
    |> cast_embed(:organizer, with: &Util.embedded_changeset/2)
  end

  defp conferencing_changeset(schema, params) do
    schema
    |> cast(params, [:provider])
    |> cast_embed(:details, with: &Util.embedded_changeset/2)
  end
end
