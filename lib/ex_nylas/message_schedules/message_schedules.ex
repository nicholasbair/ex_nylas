defmodule ExNylas.MessageSchedules do
  @moduledoc """
  Interface for Nylas message schedules.
  """

  use ExNylas,
    object: "messages/schedules",
    struct: ExNylas.MessageSchedule,
    readable_name: "message schedule",
    include: [:list, :first, :find, :all, :delete]
end
