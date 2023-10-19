defmodule ExNylas.Model.MessageSchedule do
  @moduledoc """
  A struct for Nylas message schedules.
  """

  use TypedStruct

  typedstruct do
    field(:schedule_id, String.t())
    field(:status, Status.t())
    field(:close_time, non_neg_integer())
  end

  typedstruct module: Status do
    field(:code, String.t())
    field(:description, String.t())
  end

  def as_struct(), do: struct(__MODULE__)

  def as_list(), do: [as_struct()]
end
