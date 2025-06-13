defmodule ExNylas.Calendars do
  @moduledoc """
  Interface for Nylas calendars.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/calendars)
  """

  use ExNylas,
    object: "calendars",
    struct: ExNylas.Calendar,
    readable_name: "calendar",
    include: [:list, :first, :find, :delete, :build, :create, :update, :all]
end
