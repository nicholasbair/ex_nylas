defmodule ExNylas.SchedulingBookings do
  @moduledoc """
  Interface for Nylas scheduling bookings.
  """

  use ExNylas,
    object: "scheduling/bookings",
    struct: SchedulingBooking,
    readable_name: "scheduling booking",
    include: [:create, :update, :delete],
    use_admin_url: true
end
