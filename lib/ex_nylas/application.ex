defmodule ExNylas.Application do
  @moduledoc """
  Interface for Nylas applications.
  """

  # TODO: add application callback URI endpoints

  use ExNylas,
    object: "applications",
    struct: ExNylas.Models.Application,
    include: [:list, :update],
    use_admin_url: true
end
