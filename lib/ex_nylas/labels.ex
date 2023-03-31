defmodule ExNylas.Label do
  @moduledoc """
  A struct representing a label.
  """

  defstruct [:display_name, :name, :object, :account_id, :id]

  @typedoc "A label"
  @type t :: %__MODULE__{
    display_name: String.t(),
    name: String.t(),
    object: String.t(),
    account_id: String.t(),
    id: String.t(),
  }

  def as_struct(), do: %ExNylas.Label{}

  def as_list(), do: [as_struct()]

  defmodule Build do
    @enforce_keys [:display_name]
    defstruct [:display_name]

    @typedoc "A struct representing the create label request payload."
    @type t :: %__MODULE__{display_name: String.t()}
  end
end

defmodule ExNylas.Labels do
  @moduledoc """
  Interface for Nylas label.
  """

  use ExNylas,
    object: "labels",
    struct: ExNylas.Label,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]
end
