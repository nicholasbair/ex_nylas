defmodule ExNylas.Scheduling.Bookings do
  @moduledoc """
  Interface for Nylas scheduling bookings.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/scheduler/)
  """

  alias ExNylas.Scheduling.Booking

  use ExNylas,
    object: "scheduling/bookings",
    struct: Booking,
    readable_name: "scheduling booking",
    include: [:build, :create, :delete, :find, :update],
    use_admin_url: true
end
