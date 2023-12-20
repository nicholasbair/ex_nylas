defmodule ExNylas.Model.Calendar.FreeBusy do
  @moduledoc """
  Structs for Nylas calendar free/busy.
  """

  use TypedStruct
  alias ExNylas.Model.Calendar.FreeBusy.TimeSlot

  typedstruct do
    field(:object, String.t())
    field(:email, String.t())
    field(:time_slots, [TimeSlot.t()])
  end

  typedstruct module: Build do
    field(:start_time, non_neg_integer())
    field(:end_time, non_neg_integer())
    field(:emails, list())
  end

  def as_struct() do
    %__MODULE__{
      time_slots: [TimeSlot.as_struct()]
    }
  end

  def as_list(), do: [as_struct()]

  defmodule TimeSlot do
    @moduledoc """
    Struct for Nylas calendar free/busy time slots.
    """

    typedstruct do
      field(:object, String.t())
      field(:status, String.t())
      field(:start_time, non_neg_integer())
      field(:end_time, non_neg_integer())
    end

    def as_struct(), do: struct(__MODULE__)
  end
end
