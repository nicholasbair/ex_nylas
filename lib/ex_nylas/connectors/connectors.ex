defmodule ExNylas.Connectors do
  @moduledoc """
  Interface for Nylas connector.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/connectors-integrations)
  """

  use ExNylas,
    object: "connectors",
    struct: ExNylas.Connector,
    readable_name: "connector",
    use_admin_url: true,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all],
    use_cursor_paging: false
end
