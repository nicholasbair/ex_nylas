defmodule ExNylas.RoomResources do
  @moduledoc """
  Interface for Nylas room resources.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/room-resources)
  """

  use ExNylas,
    object: "resources",
    struct: ExNylas.RoomResource,
    readable_name: "room resource",
    include: [:list, :all, :first]
end
