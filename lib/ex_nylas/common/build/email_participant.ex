defmodule ExNylas.Common.Build.EmailParticipant do
  @moduledoc """
  Helper module for building an email participant.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          email: String.t(),
          name: String.t()
        }

  @primary_key false
  @derive {Jason.Encoder, only: [:email, :name]}

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
