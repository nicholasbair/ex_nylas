defmodule ExNylas.Calendar do
  @moduledoc """
  A struct representing a calendar.
  """

  defstruct [
    :id,
    :object,
    :account_id,
    :name,
    :description,
    :read_only,
    :location,
    :timezone,
    :metadata,
    :is_primary,
    :hex_color,
  ]

  @typedoc "A calendar"
  @type t :: %__MODULE__{
    id: String.t(),
    object: String.t(),
    account_id: String.t(),
    name: String.t(),
    description: String.t(),
    read_only: boolean(),
    location: String.t(),
    timezone: String.t(),
    metadata: map(),
    is_primary: boolean(),
    hex_color: String.t(),
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
