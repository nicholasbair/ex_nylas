defmodule ExNylas.Contacts do
  @moduledoc """
  A module for interacting with the Nylas Contacts API.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/contacts)
  """

  use ExNylas,
    object: "contacts",
    struct: ExNylas.Contact,
    readable_name: "contact",
    include: [:list, :first, :find, :update, :delete, :build, :all, :create]
end
