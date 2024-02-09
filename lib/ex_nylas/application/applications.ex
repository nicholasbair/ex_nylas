defmodule ExNylas.Applications do
  @moduledoc """
  Interface for Nylas applications.
  """

  use ExNylas,
    object: "applications",
    struct: ExNylas.Schema.Application,
    readable_name: "application",
    include: [:list, :update],
    use_admin_url: true
end
