defmodule ExNylas.Applications do
  @moduledoc """
  Interface for Nylas applications.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/applications)
  """

  use ExNylas,
    object: "applications",
    struct: ExNylas.Application,
    readable_name: "application",
    include: [:list, :update],
    use_admin_url: true
end
