defmodule ExNylas.Connectors do
  @moduledoc """
  Interface for Nylas connector.
  """

  use ExNylas,
    object: "connectors",
    struct: ExNylas.Schema.Connector,
    readable_name: "connector",
    use_admin_url: true,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all],
    use_cursor_paging: false
end
