defmodule ExNylas.Label do
  @moduledoc """
  A struct representing a label.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A label"
    field(:display_name, String.t())
    field(:name, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
    field(:id, String.t())
  end

  typedstruct module: Build do
    @typedoc "A struct representing the create label request payload."
    field(:display_name, String.t(), enforce: true)
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
