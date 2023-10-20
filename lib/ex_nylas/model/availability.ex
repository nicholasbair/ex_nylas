defmodule ExNylas.Model.Calendar.Availability do
  @moduledoc """
  Structs for Nylas calendar availability.
  """

  use TypedStruct
  alias ExNylas.Model.Calendar.Availability.TimeSlot

  typedstruct do
    field(:order, [String.t()])
    field(:time_slots, [TimeSlot.t()])
  end

  def as_struct() do
    %__MODULE__{
      time_slots: [TimeSlot.as_struct()]
    }
  end

  defmodule TimeSlot do
    @moduledoc """
    Struct for Nylas calendar availability time slots.
    """

    typedstruct do
      field(:emails, [String.t()])
      field(:start_time, non_neg_integer())
      field(:end_time, non_neg_integer())
    end

    def as_struct(), do: struct(__MODULE__)
  end

  defmodule Build do
    @moduledoc """
    A struct representing the calendar availability request payload.
    """

    alias ExNylas.Model.Calendar.Availability.Build.{
      Participant,
      AvailabilityRule,
      OpenHour
    }

    typedstruct do
      field(:participants, [Participant.t()])
      field(:start_time, non_neg_integer())
      field(:end_time, non_neg_integer())
      field(:duration_minutes, non_neg_integer())
      field(:interval_minutes, non_neg_integer())
      field(:round_to_30_minutes, boolean())
      field(:availability_rules, [AvailabilityRule.t()])
    end

    typedstruct module: Participant do
      field(:email, String.t())
      field(:calendar_ids, [String.t()])
      field(:open_hours, [OpenHour.t()])
    end

    typedstruct module: OpenHour do
      field(:days, [integer()])
      field(:timezone, String.t())
      field(:start, String.t())
      field(:end, String.t())
      field(:exdates, [String.t()])
    end

    typedstruct module: AvailabilityRule do
      field(:availability_method, String.t())
      field(:buffer, non_neg_integer())
      field(:default_open_hours, [OpenHour.t()])
      field(:round_robin_group_id, String.t())
    end
  end
end
