defmodule ExNylas.Scheduling.Bookings do
  @moduledoc """
  Interface for Nylas scheduling bookings.
  """

  alias ExNylas.Scheduling.Booking

  use ExNylas,
    object: "scheduling/bookings",
    struct: Booking,
    readable_name: "scheduling booking",
    include: [:create, :update, :delete, :build],
    use_admin_url: true
end
