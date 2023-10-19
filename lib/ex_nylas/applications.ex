defmodule ExNylas.Applications do
  @moduledoc """
  Interface for Nylas applications.
  """

  use ExNylas,
    object: "applications",
    struct: ExNylas.Model.Application,
    include: [:list, :update],
    use_admin_url: true
end
