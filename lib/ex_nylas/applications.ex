defmodule ExNylas.Applications do
  @moduledoc """
  Interface for Nylas applications.
  """

  use ExNylas,
    object: "applications",
    struct: ExNylas.Models.Application,
    include: [:list, :update],
    use_admin_url: true
end
