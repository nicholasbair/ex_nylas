defmodule ExNylas.Connectors do
  @moduledoc """
  Interface for Nylas connector.
  """

  use ExNylas,
    object: "connectors",
    struct: ExNylas.Model.Connector,
    use_admin_url: true,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]
end
