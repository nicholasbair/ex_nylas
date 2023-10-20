defmodule ExNylas.Calendars do
  @moduledoc """
  Interface for Nylas calendars.
  """

  use ExNylas,
    object: "calendars",
    struct: ExNylas.Model.Calendar,
    include: [:list, :first, :find, :delete, :build, :create, :update, :all]
end
