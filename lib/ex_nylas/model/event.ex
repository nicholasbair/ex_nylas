defmodule ExNylas.Model.Event do
  @moduledoc """
  A struct representing a event.
  """

  alias ExNylas.Model.{
    Conferencing,
    Organizer,
    Participant,
    Reminder,
    When
  }

  use TypedStruct

  typedstruct do
    field(:busy, boolean())
    field(:calendar_id, String.t())
    field(:conferencing, Conferencing.t())
    field(:created_at, non_neg_integer())
    field(:description, String.t())
    field(:hide_participants, boolean())
    field(:grant_id, String.t())
    field(:html_link, String.t())
    field(:ical_uid, String.t())
    field(:id, String.t())
    field(:location, String.t())
    field(:master_event_id, String.t())
    field(:metadata, map())
    field(:object, String.t())
    field(:organizer, Organizer.t())
    field(:participants, [Participant.t()])
    field(:read_only, boolean())
    field(:reminders, Reminder.t())
    field(:recurrence, [String.t()])
    field(:status, String.t())
    field(:title, String.t())
    field(:updated_at, non_neg_integer())
    field(:visibility, String.t())
    field(:when, When.t())
  end

  typedstruct module: Reminder do
    field(:overrides, [map()])
    field(:use_default, boolean())
  end

  typedstruct module: Organizer do
    field(:email, String.t())
    field(:name, String.t())
  end

  typedstruct module: Participant do
    field(:name, String.t())
    field(:email, String.t(), enforce: true)
    field(:status, String.t())
    field(:comment, String.t())
    field(:phone_number, String.t())
  end

  typedstruct module: When do
    field(:start_time, non_neg_integer())
    field(:end_time, non_neg_integer())
    field(:start_timezone, String.t())
    field(:end_timezone, String.t())
    field(:object, String.t())
    field(:time, non_neg_integer())
    field(:timezone, String.t())
    field(:start_date, String.t())
    field(:end_date, String.t())
    field(:date, String.t())
  end

  typedstruct module: Conferencing do
    field(:meeting_code, String.t())
    field(:password, String.t())
    field(:url, String.t())
    field(:phone, [String.t()])
    field(:pin, String.t())
  end

  def as_struct do
    %__MODULE__{
      participants: [%Participant{email: nil}],
      when: %When{},
      conferencing: %Conferencing{},
      reminders: %Reminder{},
      organizer: %Organizer{},
    }
  end

  def as_list, do: [as_struct()]

  typedstruct module: Build do
    field(:calendar_id, String.t(), enforce: true)
    field(:when, map(), enforce: true)
    field(:title, String.t())
    field(:description, String.t())
    field(:location, String.t())
    field(:participants, list())
    field(:busy, boolean())
    field(:recurrence, [String.t()])
    field(:visibility, String.t())
    field(:conferencing, map())
    field(:reminder_minutes, String.t())
    field(:reminder_method, String.t())
    field(:metadata, map())
    field(:notifications, list())
    field(:hide_participants, boolean())
  end
end
