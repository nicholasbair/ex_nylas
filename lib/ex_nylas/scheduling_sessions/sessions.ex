defmodule ExNylas.SchedulingSessions do
  @moduledoc """
  Interface for Nylas scheduling sessions.
  """

  use ExNylas,
    object: "scheduling/sessions",
    struct: SchedulingSession,
    readable_name: "scheduling session",
    include: [:create, :delete],
    use_admin_url: true
end
