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

  defmodule Build do
    @moduledoc """
    A struct representing a folder.
    """
    use TypedStruct

    @derive Jason.Encoder
    typedstruct do
      @typedoc "A folder"
      field(:display_name, String.t(), enforce: true)
    end
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
