defmodule ExNylas.Folder do
  @moduledoc """
  A struct representing a folder.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A folder"
    field(:display_name, String.t())
    field(:name, String.t())
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
  end

  typedstruct module: Build do
    @typedoc "A struct representing the create folder request payload."
    field(:display_name, String.t(), enforce: true)
  end
end

defmodule ExNylas.Folders do
  @moduledoc """
  Interface for Nylas folders.
  """

  use ExNylas,
    object: "folders",
    struct: ExNylas.Folder,
    include: [:list, :first, :find, :delete, :build, :update, :create]
end
