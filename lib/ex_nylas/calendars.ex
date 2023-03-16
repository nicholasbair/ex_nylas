defmodule ExNylas.Calendar do
  @moduledoc """
  A struct representing a calendar.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A calendar"
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
    field(:name, String.t())
    field(:description, String.t())
    field(:read_only, boolean())
    field(:location, String.t())
    field(:timezone, String.t())
    field(:metadata, map())
    field(:is_primary, boolean())
    field(:hex_color, String.t())
  end

  typedstruct module: Build do
    @typedoc "A struct representing the create calendar request payload."
    field(:name, String.t(), enforce: true)
    field(:description, String.t())
    field(:location, String.t())
    field(:timezone, String.t())
  end

end

defmodule ExNylas.Calendars do
  @moduledoc """
  Interface for Nylas calendars.
  """

  use ExNylas,
    object: "calendars",
    struct: ExNylas.Calendar,
    include: [:list, :first, :find, :delete, :build, :create, :update, :all]

end
