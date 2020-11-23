defmodule ExNylas.Label do
  @moduledoc """
  A struct representing a label.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A label"
    field :display_name, String.t()
    field :name,         String.t()
    field :object,       String.t()
    field :account_id,   String.t()
    field :id,           String.t()
  end

end

defmodule ExNylas.Labels do
  @moduledoc """
  Interface for Nylas label.
  """

  use ExNylas, object: "labels", struct: ExNylas.Label, except: [:search, :send]

end
