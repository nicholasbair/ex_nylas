defmodule ExNylas.Scheduling.Sessions do
  @moduledoc """
  Interface for Nylas scheduling sessions.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/scheduler/)
  """

  alias ExNylas.Scheduling.Session

  use ExNylas,
    object: "scheduling/sessions",
    struct: Session,
    readable_name: "scheduling session",
    include: [:create, :delete, :build],
    use_admin_url: true
end
