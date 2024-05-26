defmodule ExNylas.Schema.SmartCompose do
  @moduledoc """
  A struct for Nylas smart compose.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          suggestion: String.t()
        }

  @primary_key false

  embedded_schema do
    field :suggestion, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:suggestion])
  end
end
