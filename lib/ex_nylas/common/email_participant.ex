defmodule ExNylas.Common.EmailParticipant do
  @moduledoc """
  A struct representing an email participant.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          email: String.t(),
          name: String.t()
        }

  @primary_key false

  embedded_schema do
    field :email, :string
    field :name, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:email])
  end
end
