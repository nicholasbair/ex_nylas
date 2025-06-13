defmodule ExNylas.ContactGroups do
  @moduledoc """
  A module for interacting with the Nylas Contacts API.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/contacts)
  """

  use ExNylas,
    object: "contacts/groups",
    struct: ExNylas.ContactGroup,
    readable_name: "contact group",
    include: [:list, :all]
end
