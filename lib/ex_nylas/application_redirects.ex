defmodule ExNylas.ApplicationRedirects do
  @moduledoc """
  Interface for Nylas application redirects.
  """

  use ExNylas,
    object: "applications/redirect-uris",
    struct: ExNylas.Model.ApplicationRedirect,
    include: [:list, :create, :find, :update, :delete],
    use_admin_url: true
end
