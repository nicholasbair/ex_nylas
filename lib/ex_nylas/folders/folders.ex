defmodule ExNylas.Folders do
  @moduledoc """
  Interface for Nylas folders.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/folders)
  """

  use ExNylas,
    object: "folders",
    struct: ExNylas.Folder,
    readable_name: "folder",
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]
end
