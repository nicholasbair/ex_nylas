defmodule ExNylas.Scheduling.Sessions do
  @moduledoc """
  Interface for Nylas scheduling sessions.
  """

  alias ExNylas.Scheduling.Session

  use ExNylas,
    object: "scheduling/sessions",
    struct: Session,
    readable_name: "scheduling session",
    include: [:create, :delete],
    use_admin_url: true
end
