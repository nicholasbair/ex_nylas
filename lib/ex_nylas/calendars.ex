defmodule ExNylas.Calendar do
  @moduledoc """
  A struct representing a calendar.
  """

  defstruct [
    :grant_id,
    :description,
    :id,
    :is_primary,
    :name,
    :object,
    :read_only,
    :timezone,
    :hex_color,
    :hex_foreground_color,
    :is_owned_by_user,
    :metadata,
  ]

  @typedoc "A calendar"
  @type t :: %__MODULE__{
    grant_id: String.t(),
    description: String.t(),
    id: String.t(),
    is_primary: boolean(),
    name: String.t(),
    object: String.t(),
    read_only: boolean(),
    timezone: String.t(),
    hex_color: String.t(),
    hex_foreground_color: String.t(),
    is_owned_by_user: boolean(),
    metadata: map(),
  }

  def as_struct(), do: %ExNylas.Calendar{}

  def as_list(), do: [as_struct()]

  defmodule Build do
    defstruct [:name, :description, :location, :timezone]

    @typedoc "A struct representing the create calendar request payload."
    @type t :: %__MODULE__{
      name: String.t(),
      description: String.t(),
      location: String.t(),
      timezone: String.t(),
    }
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
