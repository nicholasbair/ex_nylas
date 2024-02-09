defmodule ExNylas.Contacts do
  @moduledoc """
  A module for interacting with the Nylas Contacts API.
  """

  use ExNylas,
    object: "contacts",
    struct: ExNylas.Schema.Contact,
    readable_name: "contact",
    include: [:list, :first, :find, :update, :delete, :build, :all, :create]
end
