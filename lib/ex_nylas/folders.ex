defmodule ExNylas.Folder do
  @moduledoc """
  A struct representing a folder.
  """

  defstruct [
    :display_name,
    :name,
    :id,
    :object,
    :account_id,
  ]

  @typedoc "A folder"
  @type t :: %__MODULE__{
    display_name: String.t(),
    name: String.t(),
    id: String.t(),
    object: String.t(),
    account_id: String.t(),
  }

  def as_struct(), do: %ExNylas.Folder{}

  def as_list(), do: [as_struct()]

  defmodule Build do
    @enforce_keys [:display_name]
    defstruct [:display_name]

    @typedoc "A struct representing the create folder request payload."
    @type t :: %__MODULE__{display_name: String.t()}
  end
end

defmodule ExNylas.Folders do
  @moduledoc """
  Interface for Nylas folders.
  """

  use ExNylas,
    object: "folders",
    struct: ExNylas.Folder,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]
end
