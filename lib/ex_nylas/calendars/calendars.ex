defmodule ExNylas.Calendars do
  @moduledoc """
  Interface for Nylas calendars.
  """

  use ExNylas,
    object: "calendars",
    struct: ExNylas.Schema.Calendar,
    readable_name: "calendar",
    include: [:list, :first, :find, :delete, :build, :create, :update, :all]
end
