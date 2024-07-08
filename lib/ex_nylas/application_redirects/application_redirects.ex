defmodule ExNylas.ApplicationRedirects do
  @moduledoc """
  Interface for Nylas application redirects.
  """

  use ExNylas,
    object: "applications/redirect-uris",
    struct: ExNylas.ApplicationRedirect,
    readable_name: "application redirect",
    include: [:list, :create, :find, :update, :delete, :build],
    use_admin_url: true
end
