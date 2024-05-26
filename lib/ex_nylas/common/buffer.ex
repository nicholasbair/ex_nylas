defmodule ExNylas.Common.Buffer do
  @moduledoc """
  A struct for buffer.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          before: non_neg_integer(),
          after: non_neg_integer()
        }

  @primary_key false

  embedded_schema do
    field :before, :integer
    field :after, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:before, :after])
  end
end
