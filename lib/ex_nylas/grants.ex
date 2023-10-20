defmodule ExNylas.Grants do
  @moduledoc """
  Interface for Nylas grants.
  """

  use ExNylas,
    object: "grants",
    struct: ExNylas.Model.Grant,
    include: [:find, :delete],
    use_admin_url: true
end
