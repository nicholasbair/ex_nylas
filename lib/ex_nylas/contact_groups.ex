defmodule ExNylas.ContactGroups do
  @moduledoc """
  A module for interacting with the Nylas Contacts API.
  """

  use ExNylas,
    object: "contacts/groups",
    struct: ExNylas.Model.ContactGroup,
    readable_name: "contact group",
    include: [:list, :all]
end
