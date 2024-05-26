defmodule ExNylas.Common.MessageHeader do
  @moduledoc """
  A struct representing the headers of a message.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t()
        }

  @primary_key false

  embedded_schema do
    field :name, :string
    field :value, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
