defmodule ExNylas.Folders do
  @moduledoc """
  Interface for Nylas folders.
  """

  use ExNylas,
    object: "folders",
    struct: ExNylas.Folder,
    readable_name: "folder",
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]
end
