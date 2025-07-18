defmodule ExNylas.MessageSchedules do
  @moduledoc """
  Interface for Nylas message schedules.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/messages)
  """

  use ExNylas,
    object: "messages/schedules",
    struct: ExNylas.MessageSchedule,
    readable_name: "message schedule",
    include: [:list, :first, :find, :all, :delete]
end
